import Foundation

enum AuthEndpoint {
    static func login(email: String, password: String) throws -> APIRequest {
        let body = try JSONEncoder().encode(LoginRequestDTO(email: email, password: password))
        return APIRequest(path: "/auth/login", method: .post, body: body, requiresAuth: false)
    }

    static func refresh(refreshToken: String) throws -> APIRequest {
        let body = try JSONEncoder().encode(RefreshRequestDTO(refreshToken: refreshToken))
        return APIRequest(path: "/auth/refresh", method: .post, body: body, requiresAuth: false)
    }

    static func logout() -> APIRequest {
        APIRequest(path: "/auth/logout", method: .post)
    }
}
