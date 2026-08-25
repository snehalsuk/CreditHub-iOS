import Foundation

struct RepaymentInstallment: Identifiable, Codable, Equatable {
    let id: String
    let accountId: String
    let dueDate: Date
    let amountDue: Decimal
    let currency: String
    let status: RepaymentStatus
}

enum RepaymentStatus: String, Codable {
    case upcoming
    case due
    case paid
    case overdue
}
