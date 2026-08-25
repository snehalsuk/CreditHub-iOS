import Foundation
import Observation

@Observable
final class DashboardViewModel {
    enum State {
        case loading
        case loaded(accounts: [CreditAccount], recentTransactions: [Transaction])
        case failed(String)
    }

    var state: State = .loading

    private let fetchDashboardUseCase: FetchDashboardUseCase

    init(fetchDashboardUseCase: FetchDashboardUseCase) {
        self.fetchDashboardUseCase = fetchDashboardUseCase
    }

    @MainActor
    func load() async {
        state = .loading
        do {
            let summary = try await fetchDashboardUseCase()
            state = .loaded(accounts: summary.accounts, recentTransactions: summary.recentTransactions)
        } catch {
            state = .failed("We couldn't load your dashboard. Pull to refresh to try again.")
        }
    }
}
