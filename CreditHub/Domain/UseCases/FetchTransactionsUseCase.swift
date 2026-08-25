import Foundation

struct FetchTransactionsUseCase {
    let transactionRepository: TransactionRepository

    func callAsFunction(accountId: String) async throws -> [Transaction] {
        try await transactionRepository.fetchTransactions(accountId: accountId)
    }
}
