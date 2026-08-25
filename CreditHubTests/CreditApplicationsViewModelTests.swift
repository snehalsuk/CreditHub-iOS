import XCTest
@testable import CreditHub

@MainActor
final class CreditApplicationsViewModelTests: XCTestCase {
    func test_submitApplication_withInvalidAmount_setsErrorAndDoesNotCallUseCase() async {
        let creditRepository = FakeCreditRepository()
        let viewModel = CreditApplicationsViewModel(
            fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase(creditRepository: creditRepository),
            submitCreditApplicationUseCase: SubmitCreditApplicationUseCase(creditRepository: creditRepository)
        )
        viewModel.newRequestedAmount = "not-a-number"

        await viewModel.submitApplication()

        XCTAssertEqual(viewModel.errorMessage, "Enter a valid amount.")
        XCTAssertTrue(viewModel.applications.isEmpty)
    }

    func test_submitApplication_withValidAmount_prependsNewApplication() async {
        let creditRepository = FakeCreditRepository()
        let newApplication = CreditApplication(id: "app_new", productName: "Personal Credit Line", requestedAmount: 5000, currency: "USD", status: .submitted, submittedAt: Date())
        creditRepository.submitResult = .success(newApplication)

        let viewModel = CreditApplicationsViewModel(
            fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase(creditRepository: creditRepository),
            submitCreditApplicationUseCase: SubmitCreditApplicationUseCase(creditRepository: creditRepository)
        )
        viewModel.newRequestedAmount = "5000"

        await viewModel.submitApplication()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.applications.first?.id, "app_new")
        XCTAssertEqual(viewModel.newRequestedAmount, "")
    }
}
