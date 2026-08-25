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
    @State private var session = SessionStore(isAuthenticated: false)

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
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            ApplicationListView()
                .tabItem { Label("Apply", systemImage: "doc.text.fill") }
            TransactionsView()
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
