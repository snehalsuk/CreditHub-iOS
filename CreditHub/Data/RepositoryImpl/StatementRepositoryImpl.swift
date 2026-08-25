import Foundation

final class StatementRepositoryImpl: StatementRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchStatements(accountId: String) async throws -> [Statement] {
        let dtos = try await apiClient.send(StatementEndpoint.statements(accountId: accountId), decoding: [StatementDTO].self)
        return dtos.map { $0.toDomain() }
    }

    func downloadDocument(statementId: String) async throws -> Data {
        try await apiClient.sendRawData(StatementEndpoint.document(statementId: statementId))
    }
}
