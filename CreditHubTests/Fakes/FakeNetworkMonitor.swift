@testable import CreditHub

final class FakeNetworkMonitor: NetworkStatusProviding {
    var isConnected: Bool

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }
}
