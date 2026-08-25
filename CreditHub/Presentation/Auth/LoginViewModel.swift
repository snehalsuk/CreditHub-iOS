import Foundation
import Observation

@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty && !isLoading
    }

    @MainActor
    func login() async -> Bool {
        guard canSubmit else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            _ = try await loginUseCase(email: email, password: password)
            return true
        } catch {
            errorMessage = "We couldn't sign you in. Please check your credentials and try again."
            return false
        }
    }
}
