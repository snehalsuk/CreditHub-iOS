import Foundation

struct Dispute: Identifiable, Codable, Equatable {
    let id: String
    let transactionId: String
    let reason: String
    let status: DisputeStatus
    let createdAt: Date
}

enum DisputeStatus: String, Codable {
    case open
    case underReview
    case resolved
}
