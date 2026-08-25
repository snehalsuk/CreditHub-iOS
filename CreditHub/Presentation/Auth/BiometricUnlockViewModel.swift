import Foundation
import Observation

@Observable
final class BiometricUnlockViewModel {
    var isAuthenticating = false
    var errorMessage: String?

    private let biometricAuth: BiometricAuthManager

    init(biometricAuth: BiometricAuthManager) {
        self.biometricAuth = biometricAuth
    }

    var biometricLabel: String {
        switch biometricAuth.availableBiometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "Passcode"
        }
    }

    @MainActor
    func unlock() async -> Bool {
        isAuthenticating = true
        errorMessage = nil
        defer { isAuthenticating = false }
        do {
            try await biometricAuth.authenticate(reason: "Unlock CreditHub to view your accounts.")
            return true
        } catch {
            errorMessage = "We couldn't verify it's you. Please try again."
            return false
        }
    }
}
