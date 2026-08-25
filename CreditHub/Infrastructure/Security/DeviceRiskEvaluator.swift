import Foundation

enum DeviceRiskLevel {
    case normal
    case elevated(reasons: [String])
}

/// Composes jailbreak/debugger heuristics into a single risk signal, surfaced once at launch as a
/// dismissible warning rather than a hard lockout — hard-blocking on heuristic-only signals tends to
/// brick legitimate dev/test devices and gives false confidence against a genuinely motivated attacker.
@MainActor
enum DeviceRiskEvaluator {
    static func evaluate() -> DeviceRiskLevel {
        var reasons: [String] = []

        #if !DEBUG
        if DebuggerDetector.isDebuggerAttached() {
            reasons.append("A debugger appears to be attached to this app.")
        }
        #endif

        if JailbreakDetector.isJailbroken() {
            reasons.append("This device appears to be jailbroken, which weakens the app's security protections.")
        }

        return reasons.isEmpty ? .normal : .elevated(reasons: reasons)
    }
}
