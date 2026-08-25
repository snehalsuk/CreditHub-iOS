import Foundation
import SwiftData

@Model
final class TransactionModel {
    @Attribute(.unique) var id: String
    var accountId: String
    var transactionDescription: String
    var amount: Decimal
    var currency: String
    var date: Date
    var type: String
    var category: String

    init(id: String, accountId: String, transactionDescription: String, amount: Decimal, currency: String, date: Date, type: String, category: String) {
        self.id = id
        self.accountId = accountId
        self.transactionDescription = transactionDescription
        self.amount = amount
        self.currency = currency
        self.date = date
        self.type = type
        self.category = category
    }
}

extension TransactionModel {
    convenience init(from entity: Transaction) {
        self.init(
            id: entity.id,
            accountId: entity.accountId,
            transactionDescription: entity.description,
            amount: entity.amount,
            currency: entity.currency,
            date: entity.date,
            type: entity.type.rawValue,
            category: entity.category
        )
    }

    func toDomain() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            description: transactionDescription,
            amount: amount,
            currency: currency,
            date: date,
            type: TransactionType(rawValue: type) ?? .debit,
            category: category
        )
    }
}
