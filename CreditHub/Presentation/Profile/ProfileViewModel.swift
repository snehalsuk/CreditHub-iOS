import Foundation
import Observation

@Observable
final class ProfileViewModel {
    var user: User?
    var isLoading = false
    var errorMessage: String?
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
            errorMessage = "We couldn't load your profile."
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
            errorMessage = "We couldn't update your security preference."
        }
    }

    @MainActor
    func logout() async {
        try? await logoutUseCase()
    }
}
