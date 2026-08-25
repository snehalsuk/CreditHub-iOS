import Foundation

struct DisputeDTO: Codable {
    let id: String
    let transactionId: String
    let reason: String
    let status: String
    let createdAt: Date
}

extension DisputeDTO {
    func toDomain() -> Dispute {
        Dispute(id: id, transactionId: transactionId, reason: reason, status: DisputeStatus(rawValue: status) ?? .open, createdAt: createdAt)
    }
}

struct FileDisputeRequestDTO: Codable {
    let reason: String
}
