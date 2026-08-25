import Foundation

struct FetchStatementsUseCase {
    let statementRepository: StatementRepository

    func callAsFunction(accountId: String) async throws -> [Statement] {
        try await statementRepository.fetchStatements(accountId: accountId)
    }
}
