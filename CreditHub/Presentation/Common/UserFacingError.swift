import Foundation

struct UserFacingError: Equatable {
    let title: String
    let message: String
    let symbolName: String
}

/// Maps a thrown error to consistent, user-facing copy so every screen's error state reads the same way.
/// Presentation is allowed to see `APIError` (defined in the Data layer) purely for this display mapping —
/// Domain use cases never reference it, they just propagate whatever the repository throws.
enum ErrorPresenter {
    static func present(_ error: Error, fallbackMessage: String) -> UserFacingError {
        guard let apiError = error as? APIError else {
            return UserFacingError(
                title: String(localized: "error.generic.title"),
                message: fallbackMessage,
                symbolName: "exclamationmark.triangle"
            )
        }

        switch apiError {
        case .invalidURL, .decoding:
            return UserFacingError(
                title: String(localized: "error.generic.title"),
                message: fallbackMessage,
                symbolName: "exclamationmark.triangle"
            )
        case .transport:
            return UserFacingError(
                title: String(localized: "error.connection.title"),
                message: String(localized: "error.connection.message"),
                symbolName: "wifi.exclamationmark"
            )
        case .unauthorized:
            return UserFacingError(
                title: String(localized: "error.sessionExpired.title"),
                message: String(localized: "error.sessionExpired.message"),
                symbolName: "lock.trianglebadge.exclamationmark"
            )
        case .server(let statusCode, _):
            if statusCode >= 500 {
                return UserFacingError(
                    title: String(localized: "error.serverUnavailable.title"),
                    message: String(localized: "error.serverUnavailable.message"),
                    symbolName: "server.rack"
                )
            }
            return UserFacingError(
                title: String(localized: "error.requestFailed.title"),
                message: fallbackMessage,
                symbolName: "exclamationmark.triangle"
            )
        }
    }
}
