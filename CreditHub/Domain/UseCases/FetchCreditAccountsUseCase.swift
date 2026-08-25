import Foundation

struct FetchCreditAccountsUseCase {
    let creditRepository: CreditRepository

    func callAsFunction() async throws -> [CreditAccount] {
        try await creditRepository.fetchAccounts()
    }
}
