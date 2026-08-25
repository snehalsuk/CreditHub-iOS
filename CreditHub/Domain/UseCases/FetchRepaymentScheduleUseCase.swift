import Foundation

struct FetchRepaymentScheduleUseCase {
    let transactionRepository: TransactionRepository

    func callAsFunction(accountId: String) async throws -> [RepaymentInstallment] {
        try await transactionRepository.fetchRepaymentSchedule(accountId: accountId)
    }
}
