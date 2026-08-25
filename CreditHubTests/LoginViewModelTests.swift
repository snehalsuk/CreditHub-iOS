import XCTest
@testable import CreditHub

@MainActor
final class LoginViewModelTests: XCTestCase {
    func test_login_withValidCredentials_succeeds() async {
        let fakeAuthRepository = FakeAuthRepository()
        let session = AuthSession(
            accessToken: "token",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            user: User(id: "1", fullName: "Test User", email: "test@example.com", phoneNumber: "+15550000000", memberSince: Date())
        )
        fakeAuthRepository.loginResult = .success(session)
        let viewModel = LoginViewModel(loginUseCase: LoginUseCase(authRepository: fakeAuthRepository))
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        let result = await viewModel.login()

        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_login_withFailure_setsErrorMessage() async {
        let fakeAuthRepository = FakeAuthRepository()
        fakeAuthRepository.loginResult = .failure(APIError.unauthorized)
        let viewModel = LoginViewModel(loginUseCase: LoginUseCase(authRepository: fakeAuthRepository))
        viewModel.email = "test@example.com"
        viewModel.password = "wrong-password"

        let result = await viewModel.login()

        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func test_canSubmit_isFalse_whenFieldsAreEmpty() {
        let viewModel = LoginViewModel(loginUseCase: LoginUseCase(authRepository: FakeAuthRepository()))
        XCTAssertFalse(viewModel.canSubmit)
    }
}
