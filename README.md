# CreditHub — Digital Banking Credit Management Platform (iOS)

Native iOS client for a digital banking credit management platform.

## Stack
- **UI**: SwiftUI, MVVM + Clean Architecture (Presentation / Domain / Data / Infrastructure)
- **Networking**: `URLSession` + async/await, protocol-based `APIClient`
- **Auth**: OAuth2/OIDC (PKCE, native `ASWebAuthenticationSession`) + biometric unlock (`LocalAuthentication`)
- **Secure storage**: Keychain (`KeychainManager`)
- **Encryption**: CryptoKit (`CryptoManager`, AES-GCM) for local blobs beyond Keychain
- **Local database**: SwiftData
- **Push**: APNs (`PushNotificationManager`)
- **Analytics**: pluggable `AnalyticsService` protocol (no-op by default; Firebase adapter stubbed)
- **CI/CD**: GitHub Actions + Fastlane
- **Testing**: XCTest + XCUITest

## Project generation

This repo does not check in a hand-authored `.xcodeproj` — it's generated deterministically from
[`project.yml`](./project.yml) with [XcodeGen](https://github.com/yonaskolb/XcodeGen), so the project
structure stays in sync with the file system and merge conflicts on the `.pbxproj` disappear.

```bash
brew install xcodegen   # once
xcodegen generate       # regenerate CreditHub.xcodeproj after adding/removing files or editing project.yml
open CreditHub.xcodeproj
```

Run this again any time you add, move, or delete files under `CreditHub/`, `CreditHubTests/`, or
`CreditHubUITests/`.

## Running the app

The app ships with a mock API client (`Data/Network/Mock/MockAPIClient.swift`) enabled by default via
`Config.useMockAPI` in `DependencyContainer.swift`, so it runs standalone against canned fixtures with no
backend required. Build and run (⌘R) — you'll land on the login screen; any non-empty
email/password combination succeeds against the mock auth endpoint.

To point at a real backend, set `Config.useMockAPI = false` and configure `Config.apiBaseURL` /
`Config.oidc*` values.

## Architecture

```
CreditHub/
  App/              Composition root: @main entry point, AppDelegate (APNs), DependencyContainer (manual DI)
  Presentation/      SwiftUI Views + @Observable ViewModels, one folder per feature
  Domain/            Entities, UseCases, Repository protocols — no framework imports
  Data/              Network (APIClient, DTOs, endpoints, mocks), Persistence (SwiftData), Security
                      (Keychain/CryptoKit/biometrics), RepositoryImpl (Domain protocol conformances)
  Infrastructure/    OAuth/OIDC, push notifications, analytics — cross-cutting services
  Resources/         Assets, Info.plist / entitlements (both XcodeGen-managed, see project.yml)
```

Dependency rule: `Presentation → Domain ← Data`. Domain defines repository protocols; Data implements
them. Nothing in Domain imports SwiftUI, URLSession, SwiftData, or any Data-layer type.

## Testing

- `CreditHubTests` — XCTest unit tests for ViewModels and UseCases, driven against in-memory fake
  repositories (see `CreditHubTests/Fakes`).
- `CreditHubUITests` — XCUITest smoke test covering login → biometric unlock → dashboard.

Run via Xcode (⌘U) or:

```bash
xcodebuild test -scheme CreditHub -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Fastlane

```bash
bundle exec fastlane test    # run the test suite
bundle exec fastlane build   # build a release .ipa (adhoc)
bundle exec fastlane beta    # build + upload to TestFlight (requires App Store Connect API key env vars)
```

See [`fastlane/Fastfile`](./fastlane/Fastfile) and [`fastlane/Appfile`](./fastlane/Appfile).

## Status

This is an initial scaffold, not a finished product. Login → biometric unlock → Dashboard is wired
end-to-end against the mock API to establish the pattern. Credit Applications, Repayments, and Profile
have real Views/ViewModels/UseCases following the same pattern, backed by mock fixtures, ready to be
built out further. Firebase Analytics is stubbed behind a protocol — add the SPM package and
`GoogleService-Info.plist` when ready to wire it up for real.
