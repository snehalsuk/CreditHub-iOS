import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let apiClient: APIClient
    private let keychain: KeychainManager
    private let sessionKey = "com.credithub.app.authSession"

    private(set) var currentSession: AuthSession?

    init(apiClient: APIClient, keychain: KeychainManager = .shared) {
        self.apiClient = apiClient
        self.keychain = keychain
        self.currentSession = try? keychain.load(AuthSession.self, forKey: sessionKey)
    }

    func login(email: String, password: String) async throws -> AuthSession {
        let request = try AuthEndpoint.login(email: email, password: password)
        let dto = try await apiClient.send(request, decoding: AuthSessionDTO.self)
        let session = dto.toDomain()
        try persist(session)
        return session
    }

    func refreshSession() async throws -> AuthSession {
        guard let refreshToken = currentSession?.refreshToken else {
            throw APIError.unauthorized
        }
        let request = try AuthEndpoint.refresh(refreshToken: refreshToken)
        let dto = try await apiClient.send(request, decoding: AuthSessionDTO.self)
        let session = dto.toDomain()
        try persist(session)
        return session
    }

    func logout() async throws {
        try? await apiClient.send(AuthEndpoint.logout())
        currentSession = nil
        try? keychain.delete(forKey: sessionKey)
    }

    private func persist(_ session: AuthSession) throws {
        currentSession = session
        try keychain.save(session, forKey: sessionKey)
    }
}
