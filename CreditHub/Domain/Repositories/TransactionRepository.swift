import Foundation

protocol TransactionRepository {
    func fetchTransactions(accountId: String) async throws -> [Transaction]
    func fetchRepaymentSchedule(accountId: String) async throws -> [RepaymentInstallment]
}
