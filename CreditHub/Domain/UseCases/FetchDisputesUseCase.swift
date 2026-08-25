import Foundation

struct FetchDisputesUseCase {
    let disputeRepository: DisputeRepository

    func callAsFunction() async throws -> [Dispute] {
        try await disputeRepository.fetchDisputes()
    }
}
