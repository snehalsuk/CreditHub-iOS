import Foundation

protocol StatementRepository {
    func fetchStatements(accountId: String) async throws -> [Statement]
    func downloadDocument(statementId: String) async throws -> Data
}
