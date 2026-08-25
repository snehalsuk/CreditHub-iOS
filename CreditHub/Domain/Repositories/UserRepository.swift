import Foundation

protocol UserRepository {
    func fetchProfile() async throws -> User
    func updateBiometricPreference(enabled: Bool) async throws
}
