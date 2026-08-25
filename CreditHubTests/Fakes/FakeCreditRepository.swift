import Foundation
@testable import CreditHub

final class FakeCreditRepository: CreditRepository {
    var accountsResult: Result<[CreditAccount], Error> = .success([])
    var applicationsResult: Result<[CreditApplication], Error> = .success([])
    var submitResult: Result<CreditApplication, Error> = .failure(APIError.unauthorized)

    func fetchAccounts() async throws -> [CreditAccount] {
        try accountsResult.get()
    }

    func fetchApplications() async throws -> [CreditApplication] {
        try applicationsResult.get()
    }

    func submitApplication(productName: String, requestedAmount: Decimal, currency: String) async throws -> CreditApplication {
        try submitResult.get()
    }
}
