import Foundation
@testable import CreditHub

/// A scriptable `APIClient` — queue up responses with `stub(...)`/`stub(error:)` in call order, then
/// exercise the code under test. Records every request sent for assertions.
final class FakeAPIClient: APIClient {
    private enum StubbedResponse {
        case success(Data)
        case failure(Error)
    }

    private var stubbedResponses: [StubbedResponse] = []
    private(set) var sentRequests: [APIRequest] = []

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func stub<T: Encodable>(_ value: T) {
        stubbedResponses.append(.success((try? Self.encoder.encode(value)) ?? Data()))
    }

    func stub(rawData: Data) {
        stubbedResponses.append(.success(rawData))
    }

    func stub(error: Error) {
        stubbedResponses.append(.failure(error))
    }

    func send<T: Decodable>(_ request: APIRequest, decoding type: T.Type) async throws -> T {
        sentRequests.append(request)
        switch try nextResponse() {
        case .success(let data):
            return try Self.decoder.decode(T.self, from: data)
        case .failure(let error):
            throw error
        }
    }

    func send(_ request: APIRequest) async throws {
        sentRequests.append(request)
        if case .failure(let error) = try nextResponse() {
            throw error
        }
    }

    func sendRawData(_ request: APIRequest) async throws -> Data {
        sentRequests.append(request)
        switch try nextResponse() {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    private func nextResponse() throws -> StubbedResponse {
        guard !stubbedResponses.isEmpty else {
            throw APIError.server(statusCode: 500, message: "FakeAPIClient has no stubbed response queued")
        }
        return stubbedResponses.removeFirst()
    }
}
