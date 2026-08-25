@testable import CreditHub

final class FakeAuthRepository: AuthRepository {
    var currentSession: AuthSession?
    var loginResult: Result<AuthSession, Error> = .failure(APIError.unauthorized)
    var refreshResult: Result<AuthSession, Error> = .failure(APIError.unauthorized)
    private(set) var logoutCallCount = 0

    func login(email: String, password: String) async throws -> AuthSession {
        let session = try loginResult.get()
        currentSession = session
        return session
    }

    func refreshSession() async throws -> AuthSession {
        try refreshResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
        currentSession = nil
    }
}
