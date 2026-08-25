import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: String
    let accountId: String
    let lastFourDigits: String
    let network: CardNetwork
    let cardType: CardType
    let status: CardStatus
    let spendingLimit: Decimal
    let currency: String
}

enum CardNetwork: String, Codable {
    case visa
    case mastercard
    case amex
}

enum CardType: String, Codable {
    case virtual
    case physical
}

enum CardStatus: String, Codable {
    case active
    case frozen
    case closed
}

struct CardDetails: Codable, Equatable {
    let cardNumber: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
}
