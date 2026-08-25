import Foundation

enum CreditEndpoint {
    static func accounts() -> APIRequest {
        APIRequest(path: "/credit/accounts")
    }

    static func applications() -> APIRequest {
        APIRequest(path: "/credit/applications")
    }

    static func submitApplication(productName: String, requestedAmount: Decimal, currency: String) throws -> APIRequest {
        let body = try JSONEncoder().encode(SubmitApplicationRequestDTO(productName: productName, requestedAmount: requestedAmount, currency: currency))
        return APIRequest(path: "/credit/applications", method: .post, body: body)
    }
}
