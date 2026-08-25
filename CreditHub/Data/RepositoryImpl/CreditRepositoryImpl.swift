import Foundation

final class CreditRepositoryImpl: CreditRepository {
    private let apiClient: APIClient
    private let localDataSource: LocalDataSource?

    init(apiClient: APIClient, localDataSource: LocalDataSource? = nil) {
        self.apiClient = apiClient
        self.localDataSource = localDataSource
    }

    func fetchAccounts() async throws -> [CreditAccount] {
        let dtos = try await apiClient.send(CreditEndpoint.accounts(), decoding: [CreditAccountDTO].self)
        let accounts = dtos.map { $0.toDomain() }
        try? await localDataSource?.replaceAccounts(accounts)
        return accounts
    }

    func fetchApplications() async throws -> [CreditApplication] {
        let dtos = try await apiClient.send(CreditEndpoint.applications(), decoding: [CreditApplicationDTO].self)
        return dtos.map { $0.toDomain() }
    }

    func submitApplication(productName: String, requestedAmount: Decimal, currency: String) async throws -> CreditApplication {
        let request = try CreditEndpoint.submitApplication(productName: productName, requestedAmount: requestedAmount, currency: currency)
        let dto = try await apiClient.send(request, decoding: CreditApplicationDTO.self)
        return dto.toDomain()
    }
}
