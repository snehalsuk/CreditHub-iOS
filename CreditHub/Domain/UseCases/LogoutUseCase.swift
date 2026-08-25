import Foundation

struct LogoutUseCase {
    let authRepository: AuthRepository

    func callAsFunction() async throws {
        try await authRepository.logout()
    }
}
