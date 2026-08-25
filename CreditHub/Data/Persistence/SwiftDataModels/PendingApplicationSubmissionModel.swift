import Foundation
import SwiftData

/// A credit application submission queued locally because it was created while offline. Flushed by
/// `CreditApplicationOutbox` once connectivity returns.
@Model
final class PendingApplicationSubmissionModel {
    @Attribute(.unique) var id: String
    var productName: String
    var requestedAmount: Decimal
    var currency: String
    var createdAt: Date

    init(id: String = UUID().uuidString, productName: String, requestedAmount: Decimal, currency: String, createdAt: Date = Date()) {
        self.id = id
        self.productName = productName
        self.requestedAmount = requestedAmount
        self.currency = currency
        self.createdAt = createdAt
    }
}

/// Sendable snapshot used to move pending submissions out of the `LocalDataSource` actor.
struct PendingApplicationSubmission: Sendable, Identifiable {
    let id: String
    let productName: String
    let requestedAmount: Decimal
    let currency: String
}
