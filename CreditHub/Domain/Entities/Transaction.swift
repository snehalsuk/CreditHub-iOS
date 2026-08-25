import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: String
    let accountId: String
    let description: String
    let amount: Decimal
    let currency: String
    let date: Date
    let type: TransactionType
    let category: String
}

enum TransactionType: String, Codable {
    case debit
    case credit
}
