import Foundation

protocol CreditRepository {
    func fetchAccounts() async throws -> [CreditAccount]
    func fetchApplications() async throws -> [CreditApplication]
    func submitApplication(productName: String, requestedAmount: Decimal, currency: String) async throws -> CreditApplication
}
