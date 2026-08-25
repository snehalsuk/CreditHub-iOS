import Foundation

struct FetchCardsUseCase {
    let cardRepository: CardRepository

    func callAsFunction(accountId: String) async throws -> [Card] {
        try await cardRepository.fetchCards(accountId: accountId)
    }
}
