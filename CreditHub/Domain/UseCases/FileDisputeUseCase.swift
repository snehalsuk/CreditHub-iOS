import Foundation

struct FileDisputeUseCase {
    let disputeRepository: DisputeRepository

    func callAsFunction(transactionId: String, reason: String) async throws -> Dispute {
        try await disputeRepository.fileDispute(transactionId: transactionId, reason: reason)
    }
}
