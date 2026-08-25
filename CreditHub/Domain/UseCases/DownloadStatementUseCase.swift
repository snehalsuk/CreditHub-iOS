import Foundation

struct DownloadStatementUseCase {
    let statementRepository: StatementRepository

    func callAsFunction(statementId: String) async throws -> Data {
        try await statementRepository.downloadDocument(statementId: statementId)
    }
}
