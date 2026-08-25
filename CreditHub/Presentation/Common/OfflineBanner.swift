import SwiftUI

struct OfflineBanner: View {
    var body: some View {
        Label("You're offline. Some information may be out of date.", systemImage: "wifi.slash")
            .font(.footnote.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.warning)
            .foregroundStyle(.white)
            .accessibilityElement(children: .combine)
    }
}
