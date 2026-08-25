import Foundation
import Observation

/// Tracks how long the app has been backgrounded so `RootView` can force a biometric re-unlock after an
/// idle period, instead of trusting a session that's been backgrounded indefinitely.
@Observable
final class SessionTimeoutManager {
    private(set) var backgroundedAt: Date?
    let idleTimeout: TimeInterval

    init(idleTimeout: TimeInterval = Config.sessionIdleTimeout) {
        self.idleTimeout = idleTimeout
    }

    func recordBackgrounded() {
        backgroundedAt = Date()
    }

    func recordForegrounded() {
        backgroundedAt = nil
    }

    func shouldLockOnForeground() -> Bool {
        guard let backgroundedAt else { return false }
        return Date().timeIntervalSince(backgroundedAt) >= idleTimeout
    }
}
