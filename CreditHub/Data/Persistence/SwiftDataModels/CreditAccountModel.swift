import Foundation
import SwiftData

@Model
final class CreditAccountModel {
    @Attribute(.unique) var id: String
    var productName: String
    var accountNumberMasked: String
    var creditLimit: Decimal
    var availableCredit: Decimal
    var currentBalance: Decimal
    var currency: String
    var status: String
    var cachedAt: Date

    init(id: String, productName: String, accountNumberMasked: String, creditLimit: Decimal, availableCredit: Decimal, currentBalance: Decimal, currency: String, status: String, cachedAt: Date = Date()) {
        self.id = id
        self.productName = productName
        self.accountNumberMasked = accountNumberMasked
        self.creditLimit = creditLimit
        self.availableCredit = availableCredit
        self.currentBalance = currentBalance
        self.currency = currency
        self.status = status
        self.cachedAt = cachedAt
    }
}

extension CreditAccountModel {
    convenience init(from entity: CreditAccount) {
        self.init(
            id: entity.id,
            productName: entity.productName,
            accountNumberMasked: entity.accountNumberMasked,
            creditLimit: entity.creditLimit,
            availableCredit: entity.availableCredit,
            currentBalance: entity.currentBalance,
            currency: entity.currency,
            status: entity.status.rawValue
        )
    }

    func toDomain() -> CreditAccount {
        CreditAccount(
            id: id,
            productName: productName,
            accountNumberMasked: accountNumberMasked,
            creditLimit: creditLimit,
            availableCredit: availableCredit,
            currentBalance: currentBalance,
            currency: currency,
            status: CreditAccountStatus(rawValue: status) ?? .pending
        )
    }
}
