import XCTest
@testable import CreditHub

@MainActor
final class StatementsViewModelTests: XCTestCase {
    func test_load_populatesStatementsForPrimaryAccount() async {
        let creditRepository = FakeCreditRepository()
        creditRepository.accountsResult = .success([
            CreditAccount(id: "acct_1", productName: "Test", accountNumberMasked: "1234", creditLimit: 1000, availableCredit: 500, currentBalance: 500, currency: "USD", status: .active)
        ])
        let statementRepository = FakeStatementRepository()
        statementRepository.statementsResult = .success([
            Statement(id: "stmt_1", accountId: "acct_1", periodStart: Date(), periodEnd: Date(), issuedDate: Date())
        ])

        let viewModel = StatementsViewModel(
            fetchCreditAccountsUseCase: FetchCreditAccountsUseCase(creditRepository: creditRepository),
            fetchStatementsUseCase: FetchStatementsUseCase(statementRepository: statementRepository),
            downloadStatementUseCase: DownloadStatementUseCase(statementRepository: statementRepository)
        )

        await viewModel.load()

        XCTAssertEqual(viewModel.statements.count, 1)
    }

    func test_downloadDocument_returnsDataOnSuccess() async {
        let creditRepository = FakeCreditRepository()
        let statementRepository = FakeStatementRepository()
        let expectedData = Data("pdf-bytes".utf8)
        statementRepository.documentResult = .success(expectedData)

        let viewModel = StatementsViewModel(
            fetchCreditAccountsUseCase: FetchCreditAccountsUseCase(creditRepository: creditRepository),
            fetchStatementsUseCase: FetchStatementsUseCase(statementRepository: statementRepository),
            downloadStatementUseCase: DownloadStatementUseCase(statementRepository: statementRepository)
        )

        let result = await viewModel.downloadDocument(for: Statement(id: "stmt_1", accountId: "acct_1", periodStart: Date(), periodEnd: Date(), issuedDate: Date()))

        XCTAssertEqual(result, expectedData)
    }

    func test_downloadDocument_onFailure_setsErrorAndReturnsNil() async {
        let creditRepository = FakeCreditRepository()
        let statementRepository = FakeStatementRepository()
        statementRepository.documentResult = .failure(APIError.transport("offline"))

        let viewModel = StatementsViewModel(
            fetchCreditAccountsUseCase: FetchCreditAccountsUseCase(creditRepository: creditRepository),
            fetchStatementsUseCase: FetchStatementsUseCase(statementRepository: statementRepository),
            downloadStatementUseCase: DownloadStatementUseCase(statementRepository: statementRepository)
        )

        let result = await viewModel.downloadDocument(for: Statement(id: "stmt_1", accountId: "acct_1", periodStart: Date(), periodEnd: Date(), issuedDate: Date()))

        XCTAssertNil(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
