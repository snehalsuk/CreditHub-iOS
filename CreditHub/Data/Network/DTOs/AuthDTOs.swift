import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct RefreshRequestDTO: Encodable {
    let refreshToken: String
}

struct AuthSessionDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let user: UserDTO
}

extension AuthSessionDTO {
    func toDomain() -> AuthSession {
        AuthSession(accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiresAt, user: user.toDomain())
    }
}
