import Foundation

enum CardEndpoint {
    static func cards(accountId: String) -> APIRequest {
        APIRequest(path: "/accounts/\(accountId)/cards")
    }

    static func setStatus(cardId: String, status: CardStatus) throws -> APIRequest {
        let body = try JSONEncoder().encode(UpdateCardStatusRequestDTO(status: status.rawValue))
        return APIRequest(path: "/cards/\(cardId)/status", method: .patch, body: body)
    }

    static func updateSpendingLimit(cardId: String, limit: Decimal) throws -> APIRequest {
        let body = try JSONEncoder().encode(UpdateSpendingLimitRequestDTO(spendingLimit: limit))
        return APIRequest(path: "/cards/\(cardId)/spending-limit", method: .patch, body: body)
    }

    static func reveal(cardId: String) -> APIRequest {
        APIRequest(path: "/cards/\(cardId)/reveal")
    }
}
