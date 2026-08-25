import Foundation

/// Stands in for a real backend: decodes canned `MockFixtures` DTOs through the same
/// encode/decode path a real response would take, so the mapping code is exercised too.
/// Swap `Config.useMockAPI` to `false` and construct a `URLSessionAPIClient` once a backend exists.
final actor MockAPIClient: APIClient {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var storedApplications: [CreditApplicationDTO]
    private var storedCards: [CardDTO]
    private var storedDisputes: [DisputeDTO]

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        self.storedApplications = MockFixtures.applications
        self.storedCards = MockFixtures.cards
        self.storedDisputes = MockFixtures.disputes
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

    func sendRawData(_ request: APIRequest) async throws -> Data {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard request.method == .get, request.path.hasPrefix("/statements/"), request.path.hasSuffix("/document") else {
            throw APIError.server(statusCode: 404, message: "No mock raw-data endpoint configured for \(request.method.rawValue) \(request.path)")
        }
        let statementId = String(request.path.dropFirst("/statements/".count).dropLast("/document".count))
        return MockFixtures.placeholderStatementPDF(statementId: statementId)
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

        case (.get, let path) where path.hasSuffix("/cards"):
            return try encoder.encode(storedCards)

        case (.patch, let path) where path.hasPrefix("/cards/") && path.hasSuffix("/status"):
            let cardId = String(path.dropFirst("/cards/".count).dropLast("/status".count))
            return try updateCard(cardId: cardId) { card in
                guard let body = request.body, let decoded = try? decoder.decode(UpdateCardStatusRequestDTO.self, from: body) else { return card }
                return CardDTO(id: card.id, accountId: card.accountId, lastFourDigits: card.lastFourDigits, network: card.network, cardType: card.cardType, status: decoded.status, spendingLimit: card.spendingLimit, currency: card.currency)
            }

        case (.patch, let path) where path.hasPrefix("/cards/") && path.hasSuffix("/spending-limit"):
            let cardId = String(path.dropFirst("/cards/".count).dropLast("/spending-limit".count))
            return try updateCard(cardId: cardId) { card in
                guard let body = request.body, let decoded = try? decoder.decode(UpdateSpendingLimitRequestDTO.self, from: body) else { return card }
                return CardDTO(id: card.id, accountId: card.accountId, lastFourDigits: card.lastFourDigits, network: card.network, cardType: card.cardType, status: card.status, spendingLimit: decoded.spendingLimit, currency: card.currency)
            }

        case (.get, let path) where path.hasSuffix("/reveal"):
            return try encoder.encode(MockFixtures.cardDetails)

        case (.get, let path) where path.hasSuffix("/statements"):
            return try encoder.encode(MockFixtures.statements)

        case (.get, "/disputes"):
            return try encoder.encode(storedDisputes)

        case (.post, let path) where path.hasPrefix("/transactions/") && path.hasSuffix("/disputes"):
            let transactionId = String(path.dropFirst("/transactions/".count).dropLast("/disputes".count))
            var reason = "Unrecognized charge"
            if let body = request.body, let decoded = try? decoder.decode(FileDisputeRequestDTO.self, from: body) {
                reason = decoded.reason
            }
            let newDispute = DisputeDTO(id: UUID().uuidString, transactionId: transactionId, reason: reason, status: "open", createdAt: Date())
            storedDisputes.insert(newDispute, at: 0)
            return try encoder.encode(newDispute)

        default:
            throw APIError.server(statusCode: 404, message: "No mock configured for \(request.method.rawValue) \(request.path)")
        }
    }

    private func updateCard(cardId: String, transform: (CardDTO) -> CardDTO) throws -> Data {
        guard let index = storedCards.firstIndex(where: { $0.id == cardId }) else {
            throw APIError.server(statusCode: 404, message: "Card not found")
        }
        storedCards[index] = transform(storedCards[index])
        return try encoder.encode(storedCards[index])
    }
}
