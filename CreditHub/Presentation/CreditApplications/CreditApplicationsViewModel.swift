import Foundation
import Observation

@Observable
final class CreditApplicationsViewModel {
    var applications: [CreditApplication] = []
    var isLoading = false
    var errorMessage: String?

    var newProductName = "Personal Credit Line"
    var newRequestedAmount = ""
    var isSubmitting = false

    private let fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase
    private let submitCreditApplicationUseCase: SubmitCreditApplicationUseCase

    init(fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase, submitCreditApplicationUseCase: SubmitCreditApplicationUseCase) {
        self.fetchCreditApplicationsUseCase = fetchCreditApplicationsUseCase
        self.submitCreditApplicationUseCase = submitCreditApplicationUseCase
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            applications = try await fetchCreditApplicationsUseCase()
        } catch {
            errorMessage = "We couldn't load your applications."
        }
    }

    @MainActor
    func submitApplication() async {
        guard let amount = Decimal(string: newRequestedAmount), amount > 0 else {
            errorMessage = "Enter a valid amount."
            return
        }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            let application = try await submitCreditApplicationUseCase(productName: newProductName, requestedAmount: amount, currency: "USD")
            applications.insert(application, at: 0)
            newRequestedAmount = ""
        } catch {
            errorMessage = "We couldn't submit your application. Please try again."
        }
    }
}
