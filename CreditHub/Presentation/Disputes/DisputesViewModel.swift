import Foundation
import Observation

@Observable
final class DisputesViewModel {
    var disputes: [Dispute] = []
    var isLoading = false
    var errorMessage: UserFacingError?
    var isSubmitting = false

    private let fetchDisputesUseCase: FetchDisputesUseCase
    private let fileDisputeUseCase: FileDisputeUseCase

    init(fetchDisputesUseCase: FetchDisputesUseCase, fileDisputeUseCase: FileDisputeUseCase) {
        self.fetchDisputesUseCase = fetchDisputesUseCase
        self.fileDisputeUseCase = fileDisputeUseCase
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            disputes = try await fetchDisputesUseCase()
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "disputes.error.loadFallback"))
        }
    }

    @MainActor
    @discardableResult
    func fileDispute(transactionId: String, reason: String) async -> Bool {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            let dispute = try await fileDisputeUseCase(transactionId: transactionId, reason: reason)
            disputes.insert(dispute, at: 0)
            return true
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "disputes.error.submitFallback"))
            return false
        }
    }
}
