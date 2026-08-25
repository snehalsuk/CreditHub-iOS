@testable import CreditHub

final class FakeUserRepository: UserRepository {
    var profileResult: Result<User, Error> = .failure(APIError.unauthorized)
    private(set) var updatedBiometricPreferences: [Bool] = []
    var updatePreferenceShouldFail = false

    func fetchProfile() async throws -> User {
        try profileResult.get()
    }

    func updateBiometricPreference(enabled: Bool) async throws {
        if updatePreferenceShouldFail {
            throw APIError.unauthorized
        }
        updatedBiometricPreferences.append(enabled)
    }
}
