import Foundation

/// Decorates any `APIClient` with automatic refresh-on-401-then-retry-once. Concurrent 401s trigger only
/// one refresh (single-flight, via the actor's serialized access) — other callers await the same
/// in-flight refresh instead of hammering the token endpoint. Wraps the *base* client, not itself, so
/// `AuthRepositoryImpl.refreshSession()` never recursively triggers another refresh.
final actor AuthenticatingAPIClient: APIClient {
    private let wrapped: APIClient
    private let authRepository: AuthRepository
    private var inFlightRefresh: Task<AuthSession, Error>?

    init(wrapping client: APIClient, authRepository: AuthRepository) {
        self.wrapped = client
        self.authRepository = authRepository
    }

    func send<T: Decodable>(_ request: APIRequest, decoding type: T.Type) async throws -> T {
        do {
            return try await wrapped.send(request, decoding: type)
        } catch APIError.unauthorized where request.requiresAuth {
            try await refreshOnce()
            return try await wrapped.send(request, decoding: type)
        }
    }

    func send(_ request: APIRequest) async throws {
        do {
            try await wrapped.send(request)
        } catch APIError.unauthorized where request.requiresAuth {
            try await refreshOnce()
            try await wrapped.send(request)
        }
    }

    func sendRawData(_ request: APIRequest) async throws -> Data {
        do {
            return try await wrapped.sendRawData(request)
        } catch APIError.unauthorized where request.requiresAuth {
            try await refreshOnce()
            return try await wrapped.sendRawData(request)
        }
    }

    private func refreshOnce() async throws {
        if let inFlightRefresh {
            _ = try await inFlightRefresh.value
            return
        }
        let task = Task { try await authRepository.refreshSession() }
        inFlightRefresh = task
        defer { inFlightRefresh = nil }
        _ = try await task.value
    }
}
