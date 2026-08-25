import Foundation

struct SetCardStatusUseCase {
    let cardRepository: CardRepository

    func callAsFunction(cardId: String, status: CardStatus) async throws -> Card {
        try await cardRepository.setCardStatus(cardId: cardId, status: status)
    }
}
