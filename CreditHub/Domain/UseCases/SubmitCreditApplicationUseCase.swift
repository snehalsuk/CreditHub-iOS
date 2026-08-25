import Foundation

struct SubmitCreditApplicationUseCase {
    let creditRepository: CreditRepository

    func callAsFunction(productName: String, requestedAmount: Decimal, currency: String) async throws -> CreditApplication {
        try await creditRepository.submitApplication(productName: productName, requestedAmount: requestedAmount, currency: currency)
    }
}
