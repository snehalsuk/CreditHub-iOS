import Foundation

struct StatementDTO: Codable {
    let id: String
    let accountId: String
    let periodStart: Date
    let periodEnd: Date
    let issuedDate: Date
}

extension StatementDTO {
    func toDomain() -> Statement {
        Statement(id: id, accountId: accountId, periodStart: periodStart, periodEnd: periodEnd, issuedDate: issuedDate)
    }
}
