import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let body: Data?
    let requiresAuth: Bool

    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem] = [], body: Data? = nil, requiresAuth: Bool = true) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.requiresAuth = requiresAuth
    }
}

enum APIError: Error, Equatable {
    case invalidURL
    case transport(String)
    case unauthorized
    case server(statusCode: Int, message: String?)
    case decoding(String)
}

protocol APIClient {
    func send<T: Decodable>(_ request: APIRequest, decoding type: T.Type) async throws -> T
    func send(_ request: APIRequest) async throws
    /// For non-JSON payloads (e.g. a PDF statement download) — returns the raw response body.
    func sendRawData(_ request: APIRequest) async throws -> Data
}

/// Retries transient transport failures (timeouts, dropped connections) with exponential backoff and
/// jitter. Only applied to idempotent GET requests — retrying a POST blindly could double-submit.
private enum RetryPolicy {
    static let maxAttempts = 3
    private static let baseDelayNanoseconds: UInt64 = 300_000_000

    static func delayNanoseconds(forAttempt attempt: Int) -> UInt64 {
        let backoff = baseDelayNanoseconds * UInt64(1 << max(0, attempt - 1))
        let jitter = UInt64.random(in: 0...100_000_000)
        return backoff + jitter
    }

    static func isRetryable(_ error: URLError) -> Bool {
        [.timedOut, .networkConnectionLost, .dnsLookupFailed, .cannotConnectToHost].contains(error.code)
    }
}

/// Real network implementation over `URLSession` + async/await. Every request is routed through
/// `execute(_:)`, which attaches the bearer token (via `tokenProvider`), retries transient GET failures,
/// and maps HTTP status codes to `APIError`. Certificate pinning is enabled automatically whenever
/// `Config.pinnedPublicKeyHashes` is non-empty.
final class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: () async -> String?
    private let decoder: JSONDecoder

    init(baseURL: URL, tokenProvider: @escaping () async -> String?) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider

        let pinningDelegate = CertificatePinningDelegate(pinnedPublicKeyHashes: Config.pinnedPublicKeyHashes)
        self.session = URLSession(configuration: .default, delegate: pinningDelegate, delegateQueue: nil)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func send<T: Decodable>(_ request: APIRequest, decoding type: T.Type) async throws -> T {
        let data = try await execute(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }

    func send(_ request: APIRequest) async throws {
        _ = try await execute(request)
    }

    func sendRawData(_ request: APIRequest) async throws -> Data {
        try await execute(request)
    }

    private func execute(_ request: APIRequest) async throws -> Data {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if request.requiresAuth, let token = await tokenProvider() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var attempt = 0
        while true {
            attempt += 1
            do {
                let (data, response) = try await session.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.transport("No HTTP response received.")
                }

                switch httpResponse.statusCode {
                case 200..<300:
                    return data
                case 401:
                    throw APIError.unauthorized
                default:
                    let message = String(data: data, encoding: .utf8)
                    throw APIError.server(statusCode: httpResponse.statusCode, message: message)
                }
            } catch let urlError as URLError where request.method == .get && attempt < RetryPolicy.maxAttempts && RetryPolicy.isRetryable(urlError) {
                try await Task.sleep(nanoseconds: RetryPolicy.delayNanoseconds(forAttempt: attempt))
                continue
            } catch let urlError as URLError {
                throw APIError.transport(urlError.localizedDescription)
            } catch let apiError as APIError {
                throw apiError
            } catch {
                throw APIError.transport(error.localizedDescription)
            }
        }
    }
}
