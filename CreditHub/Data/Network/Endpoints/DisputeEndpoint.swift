import Foundation

enum DisputeEndpoint {
    static func disputes() -> APIRequest {
        APIRequest(path: "/disputes")
    }

    static func fileDispute(transactionId: String, reason: String) throws -> APIRequest {
        let body = try JSONEncoder().encode(FileDisputeRequestDTO(reason: reason))
        return APIRequest(path: "/transactions/\(transactionId)/disputes", method: .post, body: body)
    }
}
