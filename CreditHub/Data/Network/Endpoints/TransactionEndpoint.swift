import Foundation

enum TransactionEndpoint {
    static func transactions(accountId: String) -> APIRequest {
        APIRequest(path: "/accounts/\(accountId)/transactions")
    }

    static func repaymentSchedule(accountId: String) -> APIRequest {
        APIRequest(path: "/accounts/\(accountId)/repayment-schedule")
    }
}
