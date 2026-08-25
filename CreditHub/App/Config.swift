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
}
