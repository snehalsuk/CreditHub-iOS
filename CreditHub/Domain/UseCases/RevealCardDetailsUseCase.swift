import Foundation

struct RevealCardDetailsUseCase {
    let cardRepository: CardRepository

    func callAsFunction(cardId: String) async throws -> CardDetails {
        try await cardRepository.revealCardDetails(cardId: cardId)
    }
}
