import Foundation
import SwiftData

/// Actor-isolated wrapper around a SwiftData `ModelContext`, used as a local cache behind the
/// `CreditRepository` implementation so the dashboard has something to show offline.
@ModelActor
actor LocalDataSource {
    func replaceAccounts(_ accounts: [CreditAccount]) throws {
        try modelContext.delete(model: CreditAccountModel.self)
        for account in accounts {
            modelContext.insert(CreditAccountModel(from: account))
        }
        try modelContext.save()
    }

    func cachedAccounts() throws -> [CreditAccount] {
        let descriptor = FetchDescriptor<CreditAccountModel>(sortBy: [SortDescriptor(\.productName)])
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func replaceTransactions(_ transactions: [Transaction], forAccount accountId: String) throws {
        let existing = try modelContext.fetch(FetchDescriptor<TransactionModel>(predicate: #Predicate { $0.accountId == accountId }))
        for model in existing {
            modelContext.delete(model)
        }
        for transaction in transactions {
            modelContext.insert(TransactionModel(from: transaction))
        }
        try modelContext.save()
    }

    func cachedTransactions(forAccount accountId: String) throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.accountId == accountId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func queuePendingApplication(productName: String, requestedAmount: Decimal, currency: String) throws {
        modelContext.insert(PendingApplicationSubmissionModel(productName: productName, requestedAmount: requestedAmount, currency: currency))
        try modelContext.save()
    }

    func fetchPendingApplications() throws -> [PendingApplicationSubmission] {
        let descriptor = FetchDescriptor<PendingApplicationSubmissionModel>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor).map {
            PendingApplicationSubmission(id: $0.id, productName: $0.productName, requestedAmount: $0.requestedAmount, currency: $0.currency)
        }
    }

    func removePendingApplication(id: String) throws {
        let descriptor = FetchDescriptor<PendingApplicationSubmissionModel>(predicate: #Predicate { $0.id == id })
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
}
