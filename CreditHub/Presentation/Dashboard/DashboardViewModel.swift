import Foundation
import Observation

@Observable
final class DashboardViewModel {
    enum State {
        case loading
        case loaded(accounts: [CreditAccount], recentTransactions: [Transaction])
        case failed(UserFacingError)
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
            state = .failed(ErrorPresenter.present(error, fallbackMessage: String(localized: "dashboard.error.fallback")))
        }
    }
}
