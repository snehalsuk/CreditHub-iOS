@testable import CreditHub

final class FakeDisputeRepository: DisputeRepository {
    var disputesResult: Result<[Dispute], Error> = .success([])
    var fileResult: Result<Dispute, Error> = .failure(APIError.unauthorized)

    func fetchDisputes() async throws -> [Dispute] {
        try disputesResult.get()
    }

    func fileDispute(transactionId: String, reason: String) async throws -> Dispute {
        try fileResult.get()
    }
}
