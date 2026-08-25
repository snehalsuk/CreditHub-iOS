import SwiftData
import XCTest
@testable import CreditHub

@MainActor
final class CreditApplicationsViewModelTests: XCTestCase {
    private func makeOutbox(creditRepository: CreditRepository) -> CreditApplicationOutbox {
        let container = try! ModelContainer(
            for: CreditAccountModel.self, TransactionModel.self, PendingApplicationSubmissionModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let localDataSource = LocalDataSource(modelContainer: container)
        return CreditApplicationOutbox(localDataSource: localDataSource, creditRepository: creditRepository)
    }

    func test_submitApplication_withInvalidAmount_setsErrorAndDoesNotCallUseCase() async {
        let creditRepository = FakeCreditRepository()
        let viewModel = CreditApplicationsViewModel(
            fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase(creditRepository: creditRepository),
            submitCreditApplicationUseCase: SubmitCreditApplicationUseCase(creditRepository: creditRepository),
            creditApplicationOutbox: makeOutbox(creditRepository: creditRepository),
            networkMonitor: FakeNetworkMonitor(isConnected: true)
        )
        viewModel.newRequestedAmount = "not-a-number"

        await viewModel.submitApplication()

        XCTAssertEqual(viewModel.errorMessage?.message, "Enter a valid amount.")
        XCTAssertTrue(viewModel.applications.isEmpty)
    }

    func test_submitApplication_withValidAmount_prependsNewApplication() async {
        let creditRepository = FakeCreditRepository()
        let newApplication = CreditApplication(id: "app_new", productName: "Personal Credit Line", requestedAmount: 5000, currency: "USD", status: .submitted, submittedAt: Date())
        creditRepository.submitResult = .success(newApplication)

        let viewModel = CreditApplicationsViewModel(
            fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase(creditRepository: creditRepository),
            submitCreditApplicationUseCase: SubmitCreditApplicationUseCase(creditRepository: creditRepository),
            creditApplicationOutbox: makeOutbox(creditRepository: creditRepository),
            networkMonitor: FakeNetworkMonitor(isConnected: true)
        )
        viewModel.newRequestedAmount = "5000"

        await viewModel.submitApplication()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.applications.first?.id, "app_new")
        XCTAssertEqual(viewModel.newRequestedAmount, "")
    }

    func test_submitApplication_whileOffline_queuesInsteadOfSubmitting() async {
        let creditRepository = FakeCreditRepository()
        let viewModel = CreditApplicationsViewModel(
            fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase(creditRepository: creditRepository),
            submitCreditApplicationUseCase: SubmitCreditApplicationUseCase(creditRepository: creditRepository),
            creditApplicationOutbox: makeOutbox(creditRepository: creditRepository),
            networkMonitor: FakeNetworkMonitor(isConnected: false)
        )
        viewModel.newRequestedAmount = "2500"

        await viewModel.submitApplication()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.queuedOfflineNotice)
        XCTAssertTrue(viewModel.applications.isEmpty)
    }
}
