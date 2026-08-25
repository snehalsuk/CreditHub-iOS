import Foundation

protocol CardRepository {
    func fetchCards(accountId: String) async throws -> [Card]
    func setCardStatus(cardId: String, status: CardStatus) async throws -> Card
    func updateSpendingLimit(cardId: String, limit: Decimal) async throws -> Card
    func revealCardDetails(cardId: String) async throws -> CardDetails
}
