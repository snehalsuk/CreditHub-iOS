import Foundation

protocol AuthRepository: AnyObject {
    var currentSession: AuthSession? { get }
    func login(email: String, password: String) async throws -> AuthSession
    func refreshSession() async throws -> AuthSession
    func logout() async throws
}
