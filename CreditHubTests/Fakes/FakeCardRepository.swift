import Foundation
@testable import CreditHub

final class FakeCardRepository: CardRepository {
    var cardsResult: Result<[Card], Error> = .success([])
    var setStatusResult: Result<Card, Error> = .failure(APIError.unauthorized)
    var updateLimitResult: Result<Card, Error> = .failure(APIError.unauthorized)
    var revealResult: Result<CardDetails, Error> = .failure(APIError.unauthorized)

    func fetchCards(accountId: String) async throws -> [Card] {
        try cardsResult.get()
    }

    func setCardStatus(cardId: String, status: CardStatus) async throws -> Card {
        try setStatusResult.get()
    }

    func updateSpendingLimit(cardId: String, limit: Decimal) async throws -> Card {
        try updateLimitResult.get()
    }

    func revealCardDetails(cardId: String) async throws -> CardDetails {
        try revealResult.get()
    }
}
