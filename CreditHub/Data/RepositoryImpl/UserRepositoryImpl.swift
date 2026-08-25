import Foundation

final class UserRepositoryImpl: UserRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchProfile() async throws -> User {
        let dto = try await apiClient.send(UserEndpoint.profile(), decoding: UserDTO.self)
        return dto.toDomain()
    }

    func updateBiometricPreference(enabled: Bool) async throws {
        try await apiClient.send(try UserEndpoint.updateBiometricPreference(enabled: enabled))
    }
}
