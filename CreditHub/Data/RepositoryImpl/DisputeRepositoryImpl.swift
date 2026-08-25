import Foundation

final class DisputeRepositoryImpl: DisputeRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchDisputes() async throws -> [Dispute] {
        let dtos = try await apiClient.send(DisputeEndpoint.disputes(), decoding: [DisputeDTO].self)
        return dtos.map { $0.toDomain() }
    }

    func fileDispute(transactionId: String, reason: String) async throws -> Dispute {
        let request = try DisputeEndpoint.fileDispute(transactionId: transactionId, reason: reason)
        let dto = try await apiClient.send(request, decoding: DisputeDTO.self)
        return dto.toDomain()
    }
}
