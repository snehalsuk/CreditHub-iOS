import XCTest
@testable import CreditHub

final class AuthRepositoryImplTests: XCTestCase {
    override func tearDownWithError() throws {
        try? KeychainManager.shared.delete(forKey: "com.credithub.app.authSession")
        try super.tearDownWithError()
    }

    func test_login_persistsSessionAndExposesCurrentSession() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(AuthSessionDTO(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            user: UserDTO(id: "1", fullName: "Test", email: "t@example.com", phoneNumber: "+1", memberSince: Date())
        ))

        let repository = AuthRepositoryImpl(apiClient: fakeClient)
        let session = try await repository.login(email: "t@example.com", password: "pw")

        XCTAssertEqual(session.accessToken, "access")
        XCTAssertEqual(repository.currentSession?.accessToken, "access")
    }

    func test_logout_clearsCurrentSession() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(AuthSessionDTO(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            user: UserDTO(id: "1", fullName: "Test", email: "t@example.com", phoneNumber: "+1", memberSince: Date())
        ))
        let repository = AuthRepositoryImpl(apiClient: fakeClient)
        _ = try await repository.login(email: "t@example.com", password: "pw")

        fakeClient.stub(rawData: Data("{}".utf8))
        try await repository.logout()

        XCTAssertNil(repository.currentSession)
    }
}
