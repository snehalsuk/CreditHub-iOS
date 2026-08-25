import Foundation

struct DashboardSummary {
    let accounts: [CreditAccount]
    let recentTransactions: [Transaction]
}

struct FetchDashboardUseCase {
    let creditRepository: CreditRepository
    let transactionRepository: TransactionRepository

    func callAsFunction() async throws -> DashboardSummary {
        let accounts = try await creditRepository.fetchAccounts()

        var recentTransactions: [Transaction] = []
        if let primaryAccount = accounts.first {
            recentTransactions = try await transactionRepository.fetchTransactions(accountId: primaryAccount.id)
        }

        return DashboardSummary(accounts: accounts, recentTransactions: recentTransactions)
    }
}
