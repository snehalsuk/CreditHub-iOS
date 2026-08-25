import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

struct OIDCConfiguration {
    let authorizationEndpoint: URL
    let tokenEndpoint: URL
    let clientId: String
    let redirectURI: URL
    let scopes: [String]
}

struct AuthorizationCode {
    let code: String
    let codeVerifier: String
}

enum OIDCError: Error {
    case userCancelled
    case invalidCallback
}

/// Native OAuth2/OIDC authorization-code + PKCE flow using `ASWebAuthenticationSession` — no
/// third-party auth SDK required. This produces an `AuthorizationCode`; exchanging it for tokens
/// against `configuration.tokenEndpoint` is done by `AuthRepositoryImpl` via the `APIClient` once a
/// real backend/IdP is wired in (see `Config.useMockAPI`).
@MainActor
final class OIDCAuthService: NSObject {
    private let configuration: OIDCConfiguration
    private var codeVerifier: String = ""

    init(configuration: OIDCConfiguration) {
        self.configuration = configuration
    }

    func authorize() async throws -> AuthorizationCode {
        let verifier = Self.generateCodeVerifier()
        codeVerifier = verifier
        let challenge = Self.codeChallenge(for: verifier)

        var components = URLComponents(url: configuration.authorizationEndpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: configuration.clientId),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
            URLQueryItem(name: "scope", value: configuration.scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        guard let authorizationURL = components?.url, let callbackScheme = configuration.redirectURI.scheme else {
            throw OIDCError.invalidCallback
        }

        let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: authorizationURL, callbackURLScheme: callbackScheme) { url, error in
                if let url {
                    continuation.resume(returning: url)
                } else if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                    continuation.resume(throwing: OIDCError.userCancelled)
                } else {
                    continuation.resume(throwing: error ?? OIDCError.invalidCallback)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }

        guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value else {
            throw OIDCError.invalidCallback
        }

        return AuthorizationCode(code: code, codeVerifier: codeVerifier)
    }

    private static func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }

    private static func codeChallenge(for verifier: String) -> String {
        let hashed = SHA256.hash(data: Data(verifier.utf8))
        return Data(hashed).base64URLEncodedString()
    }
}

extension OIDCAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
