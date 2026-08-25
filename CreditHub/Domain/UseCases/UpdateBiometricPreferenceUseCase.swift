import Foundation

struct UpdateBiometricPreferenceUseCase {
    let userRepository: UserRepository

    func callAsFunction(enabled: Bool) async throws {
        try await userRepository.updateBiometricPreference(enabled: enabled)
    }
}
