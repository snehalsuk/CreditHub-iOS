import Foundation

struct TransactionDTO: Codable {
    let id: String
    let accountId: String
    let description: String
    let amount: Decimal
    let currency: String
    let date: Date
    let type: String
    let category: String
}

extension TransactionDTO {
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            description: description,
            amount: amount,
            currency: currency,
            date: date,
            type: TransactionType(rawValue: type) ?? .debit,
            category: category
        )
    }
}

struct RepaymentInstallmentDTO: Codable {
    let id: String
    let accountId: String
    let dueDate: Date
    let amountDue: Decimal
    let currency: String
    let status: String
}

extension RepaymentInstallmentDTO {
    func toDomain() -> RepaymentInstallment {
        RepaymentInstallment(
            id: id,
            accountId: accountId,
            dueDate: dueDate,
            amountDue: amountDue,
            currency: currency,
            status: RepaymentStatus(rawValue: status) ?? .upcoming
        )
    }
}
