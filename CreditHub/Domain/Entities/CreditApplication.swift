import Foundation

struct CreditApplication: Identifiable, Codable, Equatable {
    let id: String
    let productName: String
    let requestedAmount: Decimal
    let currency: String
    let status: CreditApplicationStatus
    let submittedAt: Date
}

enum CreditApplicationStatus: String, Codable {
    case draft
    case submitted
    case underReview
    case approved
    case rejected
}
