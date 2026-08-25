import XCTest
@testable import CreditHub

final class CreditRepositoryImplTests: XCTestCase {
    func test_fetchAccounts_mapsToDomain() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub([
            CreditAccountDTO(id: "acct_1", productName: "Test", accountNumberMasked: "1234", creditLimit: 1000, availableCredit: 500, currentBalance: 500, currency: "USD", status: "active")
        ])
        let repository = CreditRepositoryImpl(apiClient: fakeClient)

        let accounts = try await repository.fetchAccounts()

        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts.first?.status, .active)
    }

    func test_submitApplication_mapsToDomain() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(CreditApplicationDTO(id: "app_1", productName: "Test", requestedAmount: 1000, currency: "USD", status: "submitted", submittedAt: Date()))
        let repository = CreditRepositoryImpl(apiClient: fakeClient)

        let application = try await repository.submitApplication(productName: "Test", requestedAmount: 1000, currency: "USD")

        XCTAssertEqual(application.status, .submitted)
    }

    func test_fetchApplications_propagatesTransportError() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(error: APIError.transport("offline"))
        let repository = CreditRepositoryImpl(apiClient: fakeClient)

        do {
            _ = try await repository.fetchApplications()
            XCTFail("Expected an error to be thrown")
        } catch APIError.transport {
            // expected
        }
    }
}
