import Foundation
@testable import CreditHub

final class FakeStatementRepository: StatementRepository {
    var statementsResult: Result<[Statement], Error> = .success([])
    var documentResult: Result<Data, Error> = .failure(APIError.unauthorized)

    func fetchStatements(accountId: String) async throws -> [Statement] {
        try statementsResult.get()
    }

    func downloadDocument(statementId: String) async throws -> Data {
        try documentResult.get()
    }
}
