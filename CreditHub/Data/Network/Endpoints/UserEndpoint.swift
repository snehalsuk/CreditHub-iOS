import Foundation

private struct SecurityPreferencesRequestDTO: Encodable {
    let biometricEnabled: Bool
}

enum UserEndpoint {
    static func profile() -> APIRequest {
        APIRequest(path: "/user/profile")
    }

    static func updateBiometricPreference(enabled: Bool) throws -> APIRequest {
        let body = try JSONEncoder().encode(SecurityPreferencesRequestDTO(biometricEnabled: enabled))
        return APIRequest(path: "/user/security-preferences", method: .patch, body: body)
    }
}
