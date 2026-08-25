import Foundation
import SwiftData

/// Breaks the init-order cycle between `URLSessionAPIClient` (needs a token provider) and
/// `AuthRepositoryImpl` (needs the API client): the box is captured by the token-provider closure
/// and filled in once the repository exists.
private final class AuthRepositoryBox {
    var repository: AuthRepository?
}

/// Manual composition root — no DI framework. Every dependency is constructed once here and handed
/// down through initializers or the `\.dependencies` environment key. All properties are `let`,
/// assigned once during `init`, so the container is safe to share as an app-wide singleton without
/// actor isolation.
final class DependencyContainer {
    static let shared = DependencyContainer()

    let apiClient: APIClient
    let modelContainer: ModelContainer
    let localDataSource: LocalDataSource

    let keychain = KeychainManager.shared
    let biometricAuth = BiometricAuthManager.shared
    let pushNotifications = PushNotificationManager.shared
    let analytics: AnalyticsService = NoOpAnalyticsService()

    let authRepository: AuthRepository
    let creditRepository: CreditRepository
    let transactionRepository: TransactionRepository
    let userRepository: UserRepository

    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let fetchCreditAccountsUseCase: FetchCreditAccountsUseCase
    let fetchDashboardUseCase: FetchDashboardUseCase
    let fetchCreditApplicationsUseCase: FetchCreditApplicationsUseCase
    let submitCreditApplicationUseCase: SubmitCreditApplicationUseCase
    let fetchTransactionsUseCase: FetchTransactionsUseCase
    let fetchRepaymentScheduleUseCase: FetchRepaymentScheduleUseCase
    let fetchProfileUseCase: FetchProfileUseCase
    let updateBiometricPreferenceUseCase: UpdateBiometricPreferenceUseCase

    private init() {
        do {
            modelContainer = try ModelContainer(for: CreditAccountModel.self, TransactionModel.self)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
        localDataSource = LocalDataSource(modelContainer: modelContainer)

        let authRepositoryBox = AuthRepositoryBox()

        if Config.useMockAPI {
            apiClient = MockAPIClient()
        } else {
            apiClient = URLSessionAPIClient(baseURL: Config.apiBaseURL) {
                authRepositoryBox.repository?.currentSession?.accessToken
            }
        }

        let authRepositoryImpl = AuthRepositoryImpl(apiClient: apiClient)
        authRepositoryBox.repository = authRepositoryImpl
        authRepository = authRepositoryImpl

        creditRepository = CreditRepositoryImpl(apiClient: apiClient, localDataSource: localDataSource)
        transactionRepository = TransactionRepositoryImpl(apiClient: apiClient, localDataSource: localDataSource)
        userRepository = UserRepositoryImpl(apiClient: apiClient)

        loginUseCase = LoginUseCase(authRepository: authRepository)
        logoutUseCase = LogoutUseCase(authRepository: authRepository)
        fetchCreditAccountsUseCase = FetchCreditAccountsUseCase(creditRepository: creditRepository)
        fetchDashboardUseCase = FetchDashboardUseCase(creditRepository: creditRepository, transactionRepository: transactionRepository)
        fetchCreditApplicationsUseCase = FetchCreditApplicationsUseCase(creditRepository: creditRepository)
        submitCreditApplicationUseCase = SubmitCreditApplicationUseCase(creditRepository: creditRepository)
        fetchTransactionsUseCase = FetchTransactionsUseCase(transactionRepository: transactionRepository)
        fetchRepaymentScheduleUseCase = FetchRepaymentScheduleUseCase(transactionRepository: transactionRepository)
        fetchProfileUseCase = FetchProfileUseCase(userRepository: userRepository)
        updateBiometricPreferenceUseCase = UpdateBiometricPreferenceUseCase(userRepository: userRepository)
    }
}
