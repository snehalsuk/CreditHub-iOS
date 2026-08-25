import Foundation

struct CreditAccountDTO: Codable {
    let id: String
    let productName: String
    let accountNumberMasked: String
    let creditLimit: Decimal
    let availableCredit: Decimal
    let currentBalance: Decimal
    let currency: String
    let status: String
}

extension CreditAccountDTO {
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

struct CreditApplicationDTO: Codable {
    let id: String
    let productName: String
    let requestedAmount: Decimal
    let currency: String
    let status: String
    let submittedAt: Date
}

extension CreditApplicationDTO {
    func toDomain() -> CreditApplication {
        CreditApplication(
            id: id,
            productName: productName,
            requestedAmount: requestedAmount,
            currency: currency,
            status: CreditApplicationStatus(rawValue: status) ?? .draft,
            submittedAt: submittedAt
        )
    }
}

struct SubmitApplicationRequestDTO: Codable {
    let productName: String
    let requestedAmount: Decimal
    let currency: String
}
