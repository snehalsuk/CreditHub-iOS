import Foundation

/// Queues a credit application submission locally when offline, and flushes the queue through the
/// same `CreditRepository` used for online submissions once `NetworkMonitor` reports connectivity.
actor CreditApplicationOutbox {
    private let localDataSource: LocalDataSource
    private let creditRepository: CreditRepository
    private var isFlushing = false

    init(localDataSource: LocalDataSource, creditRepository: CreditRepository) {
        self.localDataSource = localDataSource
        self.creditRepository = creditRepository
    }

    func queue(productName: String, requestedAmount: Decimal, currency: String) async throws {
        try await localDataSource.queuePendingApplication(productName: productName, requestedAmount: requestedAmount, currency: currency)
    }

    func flushIfNeeded(isConnected: Bool) async {
        guard isConnected, !isFlushing else { return }
        isFlushing = true
        defer { isFlushing = false }

        guard let pending = try? await localDataSource.fetchPendingApplications() else { return }
        for submission in pending {
            do {
                _ = try await creditRepository.submitApplication(productName: submission.productName, requestedAmount: submission.requestedAmount, currency: submission.currency)
                try? await localDataSource.removePendingApplication(id: submission.id)
            } catch {
                break // Stop on first failure; the next connectivity change retries from where it left off.
            }
        }
    }
}
