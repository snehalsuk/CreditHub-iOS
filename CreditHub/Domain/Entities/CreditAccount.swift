import Foundation

struct CreditAccount: Identifiable, Codable, Equatable {
    let id: String
    let productName: String
    let accountNumberMasked: String
    let creditLimit: Decimal
    let availableCredit: Decimal
    let currentBalance: Decimal
    let currency: String
    let status: CreditAccountStatus
}

enum CreditAccountStatus: String, Codable {
    case active
    case pending
    case suspended
    case closed
}
