# CreditHub — Digital Banking Credit Management Platform (iOS)

Native iOS client for a digital banking credit management platform.

## Stack
- **UI**: SwiftUI, MVVM + Clean Architecture (Presentation / Domain / Data / Infrastructure)
- **Networking**: `URLSession` + async/await, protocol-based `APIClient`, automatic refresh-on-401
  (`AuthenticatingAPIClient`), retry-with-backoff on transient failures, certificate pinning
- **Auth**: OAuth2/OIDC (PKCE, native `ASWebAuthenticationSession`) + biometric unlock (`LocalAuthentication`)
  + step-up re-auth for sensitive actions
- **Secure storage**: Keychain (`KeychainManager`)
- **Encryption**: CryptoKit (`CryptoManager`, AES-GCM) for local blobs beyond Keychain
- **Local database**: SwiftData, including an offline outbox for queued credit application submissions
- **Security hardening**: cert pinning, jailbreak/debugger heuristics, session idle-timeout lock,
  App Switcher snapshot blur + screen-recording warning
- **Push**: APNs (`PushNotificationManager`)
- **Analytics**: pluggable `AnalyticsService` protocol (no-op by default; Firebase adapter stubbed)
- **Accessibility/localization**: VoiceOver labels on composite rows/banners, `Localizable.strings`-backed
  error copy
- **CI/CD**: GitHub Actions (lint + build + coverage-gated tests) + Fastlane
- **Testing**: XCTest (ViewModels, Repositories, networking decorators, crypto) + XCUITest

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
`Config.useMockAPI` in `Config.swift`, so it runs standalone against canned fixtures with no backend
required. Build and run (⌘R) — you'll land on the login screen; any non-empty email/password combination
succeeds against the mock auth endpoint.

To point at a real backend:
1. Set `Config.useMockAPI = false` and fill in `Config.apiBaseURL` / `Config.oidc*`.
2. Capture the backend's TLS certificate public-key SHA-256 hash(es) and set `Config.pinnedPublicKeyHashes`
   (include a backup pin for the next planned cert rotation, or connections will fail after renewal).
3. The REST contracts under `Data/Network/Endpoints/` (accounts, applications, transactions, cards,
   statements, disputes) are this app's own design, matching the mock's shapes — align them with the real
   API or update the endpoint/DTO files to match.

## Architecture

```
CreditHub/
  App/              Composition root: @main entry point, AppDelegate (APNs), DependencyContainer (manual DI)
  Presentation/      SwiftUI Views + @Observable ViewModels, one folder per feature
  Domain/            Entities, UseCases, Repository protocols — no framework imports
  Data/              Network (APIClient, DTOs, endpoints, mocks), Persistence (SwiftData), Security
                      (Keychain/CryptoKit/biometrics/cert pinning/jailbreak+debugger detection),
                      RepositoryImpl (Domain protocol conformances)
  Infrastructure/    OAuth/OIDC, push notifications, analytics, connectivity (NetworkMonitor, offline
                      outbox), security (device risk, session timeout) — cross-cutting services
  Resources/         Assets, Localizable.strings, Info.plist / entitlements (XcodeGen-managed)
```

Dependency rule: `Presentation → Domain ← Data`. Domain defines repository protocols; Data implements
them. Nothing in Domain imports SwiftUI, URLSession, SwiftData, or any Data-layer type. One deliberate,
documented exception: `Presentation/Common/UserFacingError.swift` reads the Data layer's `APIError` purely
to map it to consistent on-screen copy — Domain use cases still never reference it.

## Features

- **Dashboard** — account balances and recent activity.
- **Cards** — freeze/unfreeze, adjust spending limit, reveal full PAN/CVV (biometric step-up required).
- **Apply** — submit new credit applications; queues locally and auto-submits when offline.
- **Activity** — transactions, repayment schedule, and filing a dispute on a transaction (swipe action,
  biometric step-up required).
- **Profile** — security settings, Statements (PDF viewer via PDFKit), Disputes status, Help & Support
  (FAQ + `MFMailComposeViewController`), sign out.

## Security notes

- **Session timeout**: backgrounding the app for longer than `Config.sessionIdleTimeout` (5 minutes by
  default) forces a biometric re-unlock on return (`Infrastructure/Security/SessionTimeoutManager.swift`).
- **Step-up auth**: revealing a card number and filing a dispute re-run biometric auth via
  `.stepUpAuthRequired(...)` (`Presentation/Common/StepUpAuthModifier.swift`).
- **Device risk**: a soft, dismissible warning — not a hard lockout — appears at launch if jailbreak or
  (in Release builds only) debugger-attached heuristics fire (`Infrastructure/Security/DeviceRiskEvaluator.swift`).
- **Privacy overlay**: Dashboard, Cards, and Profile blur in the App Switcher and show a warning banner
  during active screen recording (`Presentation/Common/PrivacyOverlayModifier.swift`).
- None of this substitutes for a real security review — certificate pins, jailbreak heuristics, and the
  OIDC flow all need validation against the actual backend/IdP before shipping.

## Testing

- `CreditHubTests` — XCTest unit tests for ViewModels, Repository implementations (against a scriptable
  `FakeAPIClient`), the `AuthenticatingAPIClient` refresh-on-401 decorator, and `CryptoManager`.
- `CreditHubUITests` — XCUITest smoke test covering login → biometric unlock → dashboard. The biometric
  step needs Simulator biometrics enrolled (Features → Face ID → Enrolled) and a matching event sent
  during the run — see the note in `LoginToDashboardUITests.swift`.

Run via Xcode (⌘U) or:

```bash
xcodebuild test -scheme CreditHub -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```

## Lint

```bash
brew install swiftlint
swiftlint lint --strict
```

Config: [`.swiftlint.yml`](./.swiftlint.yml).

## Fastlane

```bash
bundle exec fastlane lint     # SwiftLint --strict
bundle exec fastlane test     # run the test suite
bundle exec fastlane build    # build a release .ipa (adhoc)
bundle exec fastlane beta     # build + upload to TestFlight (requires App Store Connect API key env vars)
```

See [`fastlane/Fastfile`](./fastlane/Fastfile) and [`fastlane/Appfile`](./fastlane/Appfile). CI
(`.github/workflows/ci.yml`) runs lint, build, and coverage-gated tests on every push/PR to `main`.

## Status

Login → biometric unlock → Dashboard, Cards, Apply, Activity, and Profile are wired end-to-end against the
mock API, including the security/networking hardening and the three newer feature areas (Cards, Statements,
Disputes/Support). Still not a finished, audited product:

- Firebase Analytics is stubbed behind a protocol — add the SPM package and `GoogleService-Info.plist` when
  ready to wire it up for real.
- `Config.pinnedPublicKeyHashes` is empty (pinning is a no-op) until real backend certs are captured.
- The REST contracts for the newer endpoints (cards/statements/disputes) are this app's own design, not
  validated against a real backend yet.
- No App Store assets (real app icon, screenshots, privacy manifest details beyond the defaults).
- This was built without access to Xcode/a Swift compiler — everything is written to compile by careful
  inspection, but hasn't been built or run. Follow the verification steps above on macOS before trusting it.
