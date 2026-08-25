import Foundation
import UIKit
import UserNotifications

protocol PushNotificationManaging {
    func requestAuthorization() async throws -> Bool
    func registerDeviceToken(_ tokenData: Data)
    func registrationFailed(_ error: Error)
}

final class PushNotificationManager: NSObject, PushNotificationManaging {
    static let shared = PushNotificationManager()

    private(set) var deviceToken: String?

    private override init() {
        super.init()
    }

    func requestAuthorization() async throws -> Bool {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        if granted {
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        }
        return granted
    }

    func registerDeviceToken(_ tokenData: Data) {
        deviceToken = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        // TODO: forward `deviceToken` to the backend via a dedicated /devices endpoint once available.
    }

    func registrationFailed(_ error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }
}

/// Handles foreground presentation of notifications while the app is active.
final class PushNotificationDelegateHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationDelegateHandler()

    private override init() {
        super.init()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
