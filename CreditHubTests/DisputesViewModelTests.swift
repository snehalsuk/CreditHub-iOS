import XCTest
@testable import CreditHub

@MainActor
final class DisputesViewModelTests: XCTestCase {
    func test_fileDispute_onSuccess_prependsDisputeAndReturnsTrue() async {
        let disputeRepository = FakeDisputeRepository()
        let newDispute = Dispute(id: "dsp_1", transactionId: "txn_1", reason: "Unrecognized charge", status: .open, createdAt: Date())
        disputeRepository.fileResult = .success(newDispute)

        let viewModel = DisputesViewModel(
            fetchDisputesUseCase: FetchDisputesUseCase(disputeRepository: disputeRepository),
            fileDisputeUseCase: FileDisputeUseCase(disputeRepository: disputeRepository)
        )

        let result = await viewModel.fileDispute(transactionId: "txn_1", reason: "Unrecognized charge")

        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.disputes.first?.id, "dsp_1")
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_fileDispute_onFailure_setsErrorAndReturnsFalse() async {
        let disputeRepository = FakeDisputeRepository()
        disputeRepository.fileResult = .failure(APIError.server(statusCode: 500, message: nil))

        let viewModel = DisputesViewModel(
            fetchDisputesUseCase: FetchDisputesUseCase(disputeRepository: disputeRepository),
            fileDisputeUseCase: FileDisputeUseCase(disputeRepository: disputeRepository)
        )

        let result = await viewModel.fileDispute(transactionId: "txn_1", reason: "Unrecognized charge")

        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.disputes.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
