import Foundation

struct FetchProfileUseCase {
    let userRepository: UserRepository

    func callAsFunction() async throws -> User {
        try await userRepository.fetchProfile()
    }
}
