import Foundation

struct LoginUseCase {
    let authRepository: AuthRepository

    func callAsFunction(email: String, password: String) async throws -> AuthSession {
        try await authRepository.login(email: email, password: password)
    }
}
