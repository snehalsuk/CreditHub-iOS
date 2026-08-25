import Foundation

final class CardRepositoryImpl: CardRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchCards(accountId: String) async throws -> [Card] {
        let dtos = try await apiClient.send(CardEndpoint.cards(accountId: accountId), decoding: [CardDTO].self)
        return dtos.map { $0.toDomain() }
    }

    func setCardStatus(cardId: String, status: CardStatus) async throws -> Card {
        let request = try CardEndpoint.setStatus(cardId: cardId, status: status)
        let dto = try await apiClient.send(request, decoding: CardDTO.self)
        return dto.toDomain()
    }

    func updateSpendingLimit(cardId: String, limit: Decimal) async throws -> Card {
        let request = try CardEndpoint.updateSpendingLimit(cardId: cardId, limit: limit)
        let dto = try await apiClient.send(request, decoding: CardDTO.self)
        return dto.toDomain()
    }

    func revealCardDetails(cardId: String) async throws -> CardDetails {
        let dto = try await apiClient.send(CardEndpoint.reveal(cardId: cardId), decoding: CardDetailsDTO.self)
        return dto.toDomain()
    }
}
