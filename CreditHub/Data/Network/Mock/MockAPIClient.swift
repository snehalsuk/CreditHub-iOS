import Foundation

/// Stands in for a real backend: decodes canned `MockFixtures` DTOs through the same
/// encode/decode path a real response would take, so the mapping code is exercised too.
/// Swap `Config.useMockAPI` to `false` and construct a `URLSessionAPIClient` once a backend exists.
final actor MockAPIClient: APIClient {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var storedApplications: [CreditApplicationDTO]

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        self.storedApplications = MockFixtures.applications
    }

    func send<T: Decodable>(_ request: APIRequest, decoding type: T.Type) async throws -> T {
        try await Task.sleep(nanoseconds: 300_000_000)
        let data = try responseData(for: request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding("Mock decode failed for \(request.path): \(error)")
        }
    }

    func send(_ request: APIRequest) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        _ = try responseData(for: request)
    }

    private func responseData(for request: APIRequest) throws -> Data {
        switch (request.method, request.path) {
        case (.post, "/auth/login"), (.post, "/auth/refresh"):
            return try encoder.encode(MockFixtures.session)

        case (.post, "/auth/logout"):
            return Data("{}".utf8)

        case (.get, "/credit/accounts"):
            return try encoder.encode(MockFixtures.accounts)

        case (.get, "/credit/applications"):
            return try encoder.encode(storedApplications)

        case (.post, "/credit/applications"):
            var productName = "New Application"
            var amount: Decimal = 0
            var currency = "USD"
            if let body = request.body, let decoded = try? decoder.decode(SubmitApplicationRequestDTO.self, from: body) {
                productName = decoded.productName
                amount = decoded.requestedAmount
                currency = decoded.currency
            }
            let newApplication = CreditApplicationDTO(
                id: UUID().uuidString,
                productName: productName,
                requestedAmount: amount,
                currency: currency,
                status: "submitted",
                submittedAt: Date()
            )
            storedApplications.insert(newApplication, at: 0)
            return try encoder.encode(newApplication)

        case (.get, let path) where path.hasSuffix("/transactions"):
            return try encoder.encode(MockFixtures.transactions)

        case (.get, let path) where path.hasSuffix("/repayment-schedule"):
            return try encoder.encode(MockFixtures.repaymentSchedule)

        case (.get, "/user/profile"):
            return try encoder.encode(MockFixtures.user)

        case (.patch, "/user/security-preferences"):
            return Data("{}".utf8)

        default:
            throw APIError.server(statusCode: 404, message: "No mock configured for \(request.method.rawValue) \(request.path)")
        }
    }
}
