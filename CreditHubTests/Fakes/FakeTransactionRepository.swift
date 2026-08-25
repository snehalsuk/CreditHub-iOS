@testable import CreditHub

final class FakeTransactionRepository: TransactionRepository {
    var transactionsResult: Result<[Transaction], Error> = .success([])
    var scheduleResult: Result<[RepaymentInstallment], Error> = .success([])

    func fetchTransactions(accountId: String) async throws -> [Transaction] {
        try transactionsResult.get()
    }

    func fetchRepaymentSchedule(accountId: String) async throws -> [RepaymentInstallment] {
        try scheduleResult.get()
    }
}
