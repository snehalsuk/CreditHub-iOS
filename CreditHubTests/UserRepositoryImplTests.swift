import XCTest
@testable import CreditHub

final class UserRepositoryImplTests: XCTestCase {
    func test_fetchProfile_mapsToDomain() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(UserDTO(id: "usr_1", fullName: "Alex Morgan", email: "alex@example.com", phoneNumber: "+1", memberSince: Date()))
        let repository = UserRepositoryImpl(apiClient: fakeClient)

        let user = try await repository.fetchProfile()

        XCTAssertEqual(user.id, "usr_1")
    }

    func test_updateBiometricPreference_sendsRequest() async throws {
        let fakeClient = FakeAPIClient()
        fakeClient.stub(rawData: Data("{}".utf8))
        let repository = UserRepositoryImpl(apiClient: fakeClient)

        try await repository.updateBiometricPreference(enabled: false)

        XCTAssertEqual(fakeClient.sentRequests.first?.path, "/user/security-preferences")
    }
}
