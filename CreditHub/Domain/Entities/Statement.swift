import Foundation

struct Statement: Identifiable, Codable, Equatable {
    let id: String
    let accountId: String
    let periodStart: Date
    let periodEnd: Date
    let issuedDate: Date
}
