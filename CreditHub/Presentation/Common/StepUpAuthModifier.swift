import SwiftUI

private struct StepUpAuthModifier: ViewModifier {
    @Binding var isPresented: Bool
    let reason: String
    let biometricAuth: BiometricAuthManager
    let onSuccess: () -> Void
    let onFailure: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                guard newValue else { return }
                Task {
                    do {
                        try await biometricAuth.authenticate(reason: reason)
                        isPresented = false
                        onSuccess()
                    } catch {
                        isPresented = false
                        onFailure?()
                    }
                }
            }
    }
}

extension View {
    /// Re-runs biometric authentication before a sensitive action proceeds (revealing a card number,
    /// filing a dispute, submitting a large credit application). Set `trigger` to `true` to kick off the
    /// check; it resets to `false` once resolved, calling `onSuccess` or `onFailure`.
    func stepUpAuthRequired(trigger: Binding<Bool>, reason: String, biometricAuth: BiometricAuthManager, onSuccess: @escaping () -> Void, onFailure: (() -> Void)? = nil) -> some View {
        modifier(StepUpAuthModifier(isPresented: trigger, reason: reason, biometricAuth: biometricAuth, onSuccess: onSuccess, onFailure: onFailure))
    }
}
