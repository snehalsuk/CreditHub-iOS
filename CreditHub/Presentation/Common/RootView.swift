import Observation
import SwiftUI

@Observable
final class SessionStore {
    var isAuthenticated: Bool
    var isUnlocked: Bool

    init(isAuthenticated: Bool, isUnlocked: Bool = false) {
        self.isAuthenticated = isAuthenticated
        self.isUnlocked = isUnlocked
    }
}

struct RootView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = SessionStore(isAuthenticated: false)
    @State private var sessionTimeoutManager = SessionTimeoutManager()
    @State private var deviceRiskReasons: [String] = []
    @State private var showDeviceRiskWarning = false

    var body: some View {
        Group {
            if !session.isAuthenticated {
                LoginView(loginUseCase: dependencies.loginUseCase)
            } else if !session.isUnlocked {
                BiometricUnlockView(biometricAuth: dependencies.biometricAuth)
            } else {
                MainTabView()
            }
        }
        .environment(\.session, session)
        .task {
            session.isAuthenticated = dependencies.authRepository.currentSession != nil
            if case .elevated(let reasons) = DeviceRiskEvaluator.evaluate() {
                deviceRiskReasons = reasons
                showDeviceRiskWarning = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                sessionTimeoutManager.recordBackgrounded()
            case .active:
                if sessionTimeoutManager.shouldLockOnForeground() {
                    session.isUnlocked = false
                }
                sessionTimeoutManager.recordForegrounded()
                Task { await dependencies.creditApplicationOutbox.flushIfNeeded(isConnected: dependencies.networkMonitor.isConnected) }
            default:
                break
            }
        }
        .alert("Security Notice", isPresented: $showDeviceRiskWarning) {
            Button("Continue", role: .cancel) {}
        } message: {
            Text(deviceRiskReasons.joined(separator: "\n"))
        }
    }
}

struct MainTabView: View {
    var body: some View {
        VStack(spacing: 0) {
            if !NetworkMonitor.shared.isConnected {
                OfflineBanner()
            }
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "house.fill") }
                CardsView()
                    .tabItem { Label("Cards", systemImage: "creditcard.fill") }
                ApplicationListView()
                    .tabItem { Label("Apply", systemImage: "doc.text.fill") }
                TransactionsView()
                    .tabItem { Label("Activity", systemImage: "list.bullet.rectangle") }
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }
        }
    }
}
