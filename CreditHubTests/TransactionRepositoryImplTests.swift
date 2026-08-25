import XCTest
@testable import CreditHub

final class TransactionRepositoryImplTests: XCTestCase {
    func test_fetchTransactions_mapsToDomain() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub([
            TransactionDTO(id: "txn_1", accountId: "acct_1", description: "Coffee", amount: 4.5, currency: "USD", date: Date(), type: "debit", category: "Dining")
        ])
        let repository = TransactionRepositoryImpl(apiClient: fakeClient)

        let transactions = try await repository.fetchTransactions(accountId: "acct_1")

        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.type, .debit)
    }

    func test_fetchRepaymentSchedule_mapsToDomain() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub([
            RepaymentInstallmentDTO(id: "rpm_1", accountId: "acct_1", dueDate: Date(), amountDue: 100, currency: "USD", status: "due")
        ])
        let repository = TransactionRepositoryImpl(apiClient: fakeClient)

        let installments = try await repository.fetchRepaymentSchedule(accountId: "acct_1")

        XCTAssertEqual(installments.first?.status, .due)
    }
}
