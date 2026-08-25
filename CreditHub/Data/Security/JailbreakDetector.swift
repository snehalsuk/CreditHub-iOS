import Foundation
import UIKit

/// Heuristic jailbreak signals — never conclusive, but a reasonable risk signal for `DeviceRiskEvaluator`
/// to fold into a soft warning rather than a hard lockout.
@MainActor
enum JailbreakDetector {
    static func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return hasSuspiciousFiles() || canWriteOutsideSandbox() || canOpenRestrictedURLScheme()
        #endif
    }

    private static let suspiciousPaths = [
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/etc/apt",
        "/private/var/lib/apt",
        "/private/var/lib/cydia",
        "/private/var/stash"
    ]

    private static func hasSuspiciousFiles() -> Bool {
        suspiciousPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    private static func canWriteOutsideSandbox() -> Bool {
        let testPath = "/private/credithub_jailbreak_test_\(UUID().uuidString).txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    private static func canOpenRestrictedURLScheme() -> Bool {
        guard let url = URL(string: "cydia://package/com.example.package") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
