import SwiftUI

struct BiometricUnlockView: View {
    @Environment(\.session) private var session
    @State private var viewModel: BiometricUnlockViewModel

    init(biometricAuth: BiometricAuthManager) {
        _viewModel = State(initialValue: BiometricUnlockViewModel(biometricAuth: biometricAuth))
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystem.Colors.primary)

            Text("Unlock with \(viewModel.biometricLabel)")
                .font(DesignSystem.Typography.headline)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.danger)
            }

            Button {
                Task {
                    if await viewModel.unlock() {
                        session.isUnlocked = true
                    }
                }
            } label: {
                if viewModel.isAuthenticating {
                    ProgressView().tint(.white).frame(maxWidth: .infinity)
                } else {
                    Text("Unlock").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .disabled(viewModel.isAuthenticating)

            Spacer()
        }
    }
}
