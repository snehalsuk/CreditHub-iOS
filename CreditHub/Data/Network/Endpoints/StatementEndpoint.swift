import Foundation

enum StatementEndpoint {
    static func statements(accountId: String) -> APIRequest {
        APIRequest(path: "/accounts/\(accountId)/statements")
    }

    static func document(statementId: String) -> APIRequest {
        APIRequest(path: "/statements/\(statementId)/document")
    }
}
