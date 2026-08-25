import Foundation
import Observation

@Observable
final class RepaymentsViewModel {
    var transactions: [Transaction] = []
    var installments: [RepaymentInstallment] = []
    var isLoading = false
    var errorMessage: UserFacingError?

    private let fetchCreditAccountsUseCase: FetchCreditAccountsUseCase
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let fetchRepaymentScheduleUseCase: FetchRepaymentScheduleUseCase

    init(fetchCreditAccountsUseCase: FetchCreditAccountsUseCase, fetchTransactionsUseCase: FetchTransactionsUseCase, fetchRepaymentScheduleUseCase: FetchRepaymentScheduleUseCase) {
        self.fetchCreditAccountsUseCase = fetchCreditAccountsUseCase
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.fetchRepaymentScheduleUseCase = fetchRepaymentScheduleUseCase
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let accounts = try await fetchCreditAccountsUseCase()
            guard let primaryAccountId = accounts.first?.id else {
                transactions = []
                installments = []
                return
            }
            async let fetchedTransactions = fetchTransactionsUseCase(accountId: primaryAccountId)
            async let fetchedInstallments = fetchRepaymentScheduleUseCase(accountId: primaryAccountId)
            transactions = try await fetchedTransactions
            installments = try await fetchedInstallments
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "activity.error.fallback"))
        }
    }
}
