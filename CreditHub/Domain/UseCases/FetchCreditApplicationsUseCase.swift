import Foundation

struct FetchCreditApplicationsUseCase {
    let creditRepository: CreditRepository

    func callAsFunction() async throws -> [CreditApplication] {
        try await creditRepository.fetchApplications()
    }
}
