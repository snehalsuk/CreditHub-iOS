import Foundation

final class TransactionRepositoryImpl: TransactionRepository {
    private let apiClient: APIClient
    private let localDataSource: LocalDataSource?

    init(apiClient: APIClient, localDataSource: LocalDataSource? = nil) {
        self.apiClient = apiClient
        self.localDataSource = localDataSource
    }

    func fetchTransactions(accountId: String) async throws -> [Transaction] {
        let dtos = try await apiClient.send(TransactionEndpoint.transactions(accountId: accountId), decoding: [TransactionDTO].self)
        let transactions = dtos.map { $0.toDomain() }
        try? await localDataSource?.replaceTransactions(transactions, forAccount: accountId)
        return transactions
    }

    func fetchRepaymentSchedule(accountId: String) async throws -> [RepaymentInstallment] {
        let dtos = try await apiClient.send(TransactionEndpoint.repaymentSchedule(accountId: accountId), decoding: [RepaymentInstallmentDTO].self)
        return dtos.map { $0.toDomain() }
    }
}
