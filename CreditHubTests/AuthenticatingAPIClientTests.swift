import XCTest
@testable import CreditHub

final class AuthenticatingAPIClientTests: XCTestCase {
    func test_send_whenUnauthorized_refreshesThenRetriesOnce() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(error: APIError.unauthorized)
        fakeClient.stub(UserDTO(id: "1", fullName: "Test", email: "t@example.com", phoneNumber: "+1", memberSince: Date()))

        let fakeAuthRepository = FakeAuthRepository()
        fakeAuthRepository.refreshResult = .success(AuthSession(
            accessToken: "new",
            refreshToken: "new-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            user: User(id: "1", fullName: "Test", email: "t@example.com", phoneNumber: "+1", memberSince: Date())
        ))

        let client = AuthenticatingAPIClient(wrapping: fakeClient, authRepository: fakeAuthRepository)

        let result = try await client.send(UserEndpoint.profile(), decoding: UserDTO.self)

        XCTAssertEqual(result.id, "1")
        XCTAssertEqual(fakeClient.sentRequests.count, 2)
        XCTAssertEqual(fakeAuthRepository.refreshCallCount, 1)
    }

    func test_send_whenRefreshFails_propagatesRefreshError() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(error: APIError.unauthorized)

        let fakeAuthRepository = FakeAuthRepository()
        fakeAuthRepository.refreshResult = .failure(APIError.unauthorized)

        let client = AuthenticatingAPIClient(wrapping: fakeClient, authRepository: fakeAuthRepository)

        do {
            _ = try await client.send(UserEndpoint.profile(), decoding: UserDTO.self)
            XCTFail("Expected an error to be thrown")
        } catch APIError.unauthorized {
            XCTAssertEqual(fakeAuthRepository.refreshCallCount, 1)
        }
    }

    func test_send_whenRequestDoesNotRequireAuth_doesNotTriggerRefresh() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(error: APIError.unauthorized)
        let fakeAuthRepository = FakeAuthRepository()
        let client = AuthenticatingAPIClient(wrapping: fakeClient, authRepository: fakeAuthRepository)

        do {
            try await client.send(APIRequest(path: "/public", requiresAuth: false))
            XCTFail("Expected an error to be thrown")
        } catch APIError.unauthorized {
            XCTAssertEqual(fakeAuthRepository.refreshCallCount, 0)
        }
    }
}
