import SwiftUI

private struct PrivacyOverlayModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isScreenCaptured = UIScreen.main.isCaptured

    func body(content: Content) -> some View {
        content
            .blur(radius: scenePhase == .active ? 0 : 20)
            .overlay(alignment: .top) {
                if isScreenCaptured {
                    ScreenRecordingWarningBanner()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
                isScreenCaptured = UIScreen.main.isCaptured
            }
    }
}

private struct ScreenRecordingWarningBanner: View {
    var body: some View {
        Label("Screen recording detected — sensitive details are hidden.", systemImage: "exclamationmark.triangle.fill")
            .font(.footnote.weight(.semibold))
            .padding(DesignSystem.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.danger, in: RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.white)
            .padding(DesignSystem.Spacing.md)
            .accessibilityAddTraits(.isStaticText)
    }
}

extension View {
    /// Blurs content when the app isn't in the foreground (App Switcher snapshot protection) and shows a
    /// warning banner while screen recording is active. Apply to screens showing sensitive financial data.
    func privacyProtected() -> some View {
        modifier(PrivacyOverlayModifier())
    }
}
