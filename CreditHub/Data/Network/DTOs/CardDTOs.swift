import Foundation

struct CardDTO: Codable {
    let id: String
    let accountId: String
    let lastFourDigits: String
    let network: String
    let cardType: String
    let status: String
    let spendingLimit: Decimal
    let currency: String
}

extension CardDTO {
    func toDomain() -> Card {
        Card(
            id: id,
            accountId: accountId,
            lastFourDigits: lastFourDigits,
            network: CardNetwork(rawValue: network) ?? .visa,
            cardType: CardType(rawValue: cardType) ?? .virtual,
            status: CardStatus(rawValue: status) ?? .active,
            spendingLimit: spendingLimit,
            currency: currency
        )
    }
}

struct CardDetailsDTO: Codable {
    let cardNumber: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
}

extension CardDetailsDTO {
    func toDomain() -> CardDetails {
        CardDetails(cardNumber: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv)
    }
}

struct UpdateCardStatusRequestDTO: Codable {
    let status: String
}

struct UpdateSpendingLimitRequestDTO: Codable {
    let spendingLimit: Decimal
}
