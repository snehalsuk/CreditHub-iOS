import Foundation
import Observation

@Observable
final class CreditApplicationsViewModel {
    var applications: [CreditApplication] = []
    var isLoading = false
    var errorMessage: UserFacingError?
    var queuedOfflineNotice: String?

    var newProductName = "Personal Credit Line"
    var newRequestedAmount = ""
    var isSubmitting = false

    private let fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase
    private let submitCreditApplicationUseCase: SubmitCreditApplicationUseCase
    private let creditApplicationOutbox: CreditApplicationOutbox
    private let networkMonitor: NetworkStatusProviding

    init(fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase, submitCreditApplicationUseCase: SubmitCreditApplicationUseCase, creditApplicationOutbox: CreditApplicationOutbox, networkMonitor: NetworkStatusProviding) {
        self.fetchCreditApplicationsUseCase = fetchCreditApplicationsUseCase
        self.submitCreditApplicationUseCase = submitCreditApplicationUseCase
        self.creditApplicationOutbox = creditApplicationOutbox
        self.networkMonitor = networkMonitor
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            applications = try await fetchCreditApplicationsUseCase()
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "applications.error.loadFallback"))
        }
        await creditApplicationOutbox.flushIfNeeded(isConnected: networkMonitor.isConnected)
    }

    @MainActor
    func submitApplication() async {
        guard let amount = Decimal(string: newRequestedAmount), amount > 0 else {
            errorMessage = UserFacingError(
                title: String(localized: "applications.error.invalidAmount.title"),
                message: String(localized: "applications.error.invalidAmount.message"),
                symbolName: "exclamationmark.circle"
            )
            return
        }

        isSubmitting = true
        errorMessage = nil
        queuedOfflineNotice = nil
        defer { isSubmitting = false }

        guard networkMonitor.isConnected else {
            do {
                try await creditApplicationOutbox.queue(productName: newProductName, requestedAmount: amount, currency: "USD")
                queuedOfflineNotice = String(localized: "applications.offlineQueued.message")
                newRequestedAmount = ""
            } catch {
                errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "applications.error.submitFallback"))
            }
            return
        }

        do {
            let application = try await submitCreditApplicationUseCase(productName: newProductName, requestedAmount: amount, currency: "USD")
            applications.insert(application, at: 0)
            newRequestedAmount = ""
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "applications.error.submitFallback"))
        }
    }
}
