import Foundation

struct UpdateCardSpendingLimitUseCase {
    let cardRepository: CardRepository

    func callAsFunction(cardId: String, limit: Decimal) async throws -> Card {
        try await cardRepository.updateSpendingLimit(cardId: cardId, limit: limit)
    }
}
