import Foundation

protocol AnalyticsService {
    func log(event: String, parameters: [String: Any]?)
    func setUserId(_ id: String?)
}

final class NoOpAnalyticsService: AnalyticsService {
    func log(event: String, parameters: [String: Any]?) {}
    func setUserId(_ id: String?) {}
}

/// TODO: add the FirebaseAnalytics SPM package and a real `GoogleService-Info.plist`, uncomment the
/// calls below, and swap this adapter in via `DependencyContainer.analytics`.
final class FirebaseAnalyticsAdapter: AnalyticsService {
    func log(event: String, parameters: [String: Any]?) {
        // FirebaseAnalytics.Analytics.logEvent(event, parameters: parameters)
    }

    func setUserId(_ id: String?) {
        // FirebaseAnalytics.Analytics.setUserID(id)
    }
}
