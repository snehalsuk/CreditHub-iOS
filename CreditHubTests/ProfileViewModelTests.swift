import XCTest
@testable import CreditHub

@MainActor
final class ProfileViewModelTests: XCTestCase {
    func test_setBiometricEnabled_whenUpdateFails_revertsToPreviousValue() async {
        let userRepository = FakeUserRepository()
        userRepository.updatePreferenceShouldFail = true
        let viewModel = ProfileViewModel(
            fetchProfileUseCase: FetchProfileUseCase(userRepository: userRepository),
            updateBiometricPreferenceUseCase: UpdateBiometricPreferenceUseCase(userRepository: userRepository),
            logoutUseCase: LogoutUseCase(authRepository: FakeAuthRepository())
        )
        XCTAssertTrue(viewModel.isBiometricEnabled)

        await viewModel.setBiometricEnabled(false)

        XCTAssertTrue(viewModel.isBiometricEnabled)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func test_logout_callsAuthRepositoryLogout() async {
        let fakeAuthRepository = FakeAuthRepository()
        let userRepository = FakeUserRepository()
        let viewModel = ProfileViewModel(
            fetchProfileUseCase: FetchProfileUseCase(userRepository: userRepository),
            updateBiometricPreferenceUseCase: UpdateBiometricPreferenceUseCase(userRepository: userRepository),
            logoutUseCase: LogoutUseCase(authRepository: fakeAuthRepository)
        )

        await viewModel.logout()

        XCTAssertEqual(fakeAuthRepository.logoutCallCount, 1)
    }
}
