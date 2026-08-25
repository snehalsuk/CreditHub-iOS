import Foundation

protocol DisputeRepository {
    func fetchDisputes() async throws -> [Dispute]
    func fileDispute(transactionId: String, reason: String) async throws -> Dispute
}
