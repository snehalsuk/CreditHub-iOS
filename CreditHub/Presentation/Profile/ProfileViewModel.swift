import Foundation
import Observation

@Observable
final class ProfileViewModel {
    var user: User?
    var isLoading = false
    var errorMessage: UserFacingError?
    var isBiometricEnabled = true
    var isUpdatingPreference = false

    private let fetchProfileUseCase: FetchProfileUseCase
    private let updateBiometricPreferenceUseCase: UpdateBiometricPreferenceUseCase
    private let logoutUseCase: LogoutUseCase

    init(fetchProfileUseCase: FetchProfileUseCase, updateBiometricPreferenceUseCase: UpdateBiometricPreferenceUseCase, logoutUseCase: LogoutUseCase) {
        self.fetchProfileUseCase = fetchProfileUseCase
        self.updateBiometricPreferenceUseCase = updateBiometricPreferenceUseCase
        self.logoutUseCase = logoutUseCase
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            user = try await fetchProfileUseCase()
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "profile.error.loadFallback"))
        }
    }

    @MainActor
    func setBiometricEnabled(_ enabled: Bool) async {
        let previous = isBiometricEnabled
        isBiometricEnabled = enabled
        isUpdatingPreference = true
        defer { isUpdatingPreference = false }
        do {
            try await updateBiometricPreferenceUseCase(enabled: enabled)
        } catch {
            isBiometricEnabled = previous
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "profile.error.securityPreferenceFallback"))
        }
    }

    @MainActor
    func logout() async {
        try? await logoutUseCase()
    }
}
