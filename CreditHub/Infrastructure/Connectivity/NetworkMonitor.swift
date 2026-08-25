import Foundation
import Network
import Observation

/// Narrow seam so ViewModels (e.g. `CreditApplicationsViewModel`'s offline-queueing logic) can be
/// unit tested against a fake connectivity state instead of the real `NWPathMonitor`.
protocol NetworkStatusProviding {
    var isConnected: Bool { get }
}

@Observable
final class NetworkMonitor: NetworkStatusProviding {
    static let shared = NetworkMonitor()

    private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.credithub.app.networkmonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
