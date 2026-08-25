import Foundation

/// Central place for environment-dependent configuration. Swap `useMockAPI` to `false` and fill in
/// the real endpoints once a backend exists.
enum Config {
    static var useMockAPI = true

    static var apiBaseURL = URL(string: "https://api.credithub.example.com/v1")!

    static var oidcAuthorizationEndpoint = URL(string: "https://auth.credithub.example.com/oauth2/authorize")!
    static var oidcTokenEndpoint = URL(string: "https://auth.credithub.example.com/oauth2/token")!
    static var oidcClientId = "credithub-ios"
    static var oidcRedirectURI = URL(string: "com.credithub.app://oauth-callback")!
    static var oidcScopes = ["openid", "profile", "offline_access"]

    /// Base64-encoded SHA-256 hashes of the backend's expected TLS certificate public keys (SPKI pins).
    /// Empty by default (pinning is a no-op) until real values are captured from the production backend's
    /// certificate chain. Populate before flipping `useMockAPI` to `false`, and keep a backup pin for the
    /// next planned certificate rotation so a renewal doesn't lock the app out.
    static var pinnedPublicKeyHashes: Set<String> = []

    /// How long the app can sit backgrounded before requiring biometric re-unlock on return.
    static var sessionIdleTimeout: TimeInterval = 5 * 60
}
