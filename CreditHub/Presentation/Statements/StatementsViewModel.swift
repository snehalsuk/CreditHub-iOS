import Foundation
import Observation

@Observable
final class StatementsViewModel {
    var statements: [Statement] = []
    var isLoading = false
    var errorMessage: UserFacingError?

    private let fetchCreditAccountsUseCase: FetchCreditAccountsUseCase
    private let fetchStatementsUseCase: FetchStatementsUseCase
    private let downloadStatementUseCase: DownloadStatementUseCase

    init(fetchCreditAccountsUseCase: FetchCreditAccountsUseCase, fetchStatementsUseCase: FetchStatementsUseCase, downloadStatementUseCase: DownloadStatementUseCase) {
        self.fetchCreditAccountsUseCase = fetchCreditAccountsUseCase
        self.fetchStatementsUseCase = fetchStatementsUseCase
        self.downloadStatementUseCase = downloadStatementUseCase
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let accounts = try await fetchCreditAccountsUseCase()
            guard let primaryAccountId = accounts.first?.id else {
                statements = []
                return
            }
            statements = try await fetchStatementsUseCase(accountId: primaryAccountId)
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "statements.error.loadFallback"))
        }
    }

    @MainActor
    func downloadDocument(for statement: Statement) async -> Data? {
        do {
            return try await downloadStatementUseCase(statementId: statement.id)
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "statements.error.downloadFallback"))
            return nil
        }
    }
}
