import SwiftUI

struct ErrorStateView: View {
    let error: UserFacingError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: error.symbolName)
                .font(.largeTitle)
                .foregroundStyle(DesignSystem.Colors.danger)
            Text(error.title)
                .font(DesignSystem.Typography.headline)
            Text(error.message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
