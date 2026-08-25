import XCTest
@testable import CreditHub

@MainActor
final class DashboardViewModelTests: XCTestCase {
    func test_load_populatesAccountsAndTransactions() async {
        let creditRepository = FakeCreditRepository()
        let account = CreditAccount(id: "acct_1", productName: "Test Line", accountNumberMasked: "•••• 1234", creditLimit: 1000, availableCredit: 500, currentBalance: 500, currency: "USD", status: .active)
        creditRepository.accountsResult = .success([account])

        let transactionRepository = FakeTransactionRepository()
        transactionRepository.transactionsResult = .success([
            Transaction(id: "txn_1", accountId: "acct_1", description: "Coffee Shop", amount: 4.50, currency: "USD", date: Date(), type: .debit, category: "Dining")
        ])

        let useCase = FetchDashboardUseCase(creditRepository: creditRepository, transactionRepository: transactionRepository)
        let viewModel = DashboardViewModel(fetchDashboardUseCase: useCase)

        await viewModel.load()

        guard case .loaded(let accounts, let transactions) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(transactions.count, 1)
    }

    func test_load_whenAccountsFail_setsFailedState() async {
        let creditRepository = FakeCreditRepository()
        creditRepository.accountsResult = .failure(APIError.server(statusCode: 500, message: nil))

        let useCase = FetchDashboardUseCase(creditRepository: creditRepository, transactionRepository: FakeTransactionRepository())
        let viewModel = DashboardViewModel(fetchDashboardUseCase: useCase)

        await viewModel.load()

        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
    }
}
