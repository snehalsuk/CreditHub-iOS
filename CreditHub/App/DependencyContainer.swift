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

    /// Refresh-on-401-wrapped client used by every repository except `AuthRepositoryImpl` itself (which
    /// talks to `baseAPIClient` directly to avoid recursively triggering its own refresh).
    let apiClient: APIClient
    let modelContainer: ModelContainer
    let localDataSource: LocalDataSource

    let keychain = KeychainManager.shared
    let biometricAuth = BiometricAuthManager.shared
    let pushNotifications = PushNotificationManager.shared
    let analytics: AnalyticsService = NoOpAnalyticsService()
    let networkMonitor = NetworkMonitor.shared
    let creditApplicationOutbox: CreditApplicationOutbox

    let authRepository: AuthRepository
    let creditRepository: CreditRepository
    let transactionRepository: TransactionRepository
    let userRepository: UserRepository
    let cardRepository: CardRepository
    let statementRepository: StatementRepository
    let disputeRepository: DisputeRepository

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
    let fetchCardsUseCase: FetchCardsUseCase
    let setCardStatusUseCase: SetCardStatusUseCase
    let updateCardSpendingLimitUseCase: UpdateCardSpendingLimitUseCase
    let revealCardDetailsUseCase: RevealCardDetailsUseCase
    let fetchStatementsUseCase: FetchStatementsUseCase
    let downloadStatementUseCase: DownloadStatementUseCase
    let fetchDisputesUseCase: FetchDisputesUseCase
    let fileDisputeUseCase: FileDisputeUseCase

    private init() {
        do {
            modelContainer = try ModelContainer(for: CreditAccountModel.self, TransactionModel.self, PendingApplicationSubmissionModel.self)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
        localDataSource = LocalDataSource(modelContainer: modelContainer)

        let authRepositoryBox = AuthRepositoryBox()

        let baseAPIClient: APIClient
        if Config.useMockAPI {
            baseAPIClient = MockAPIClient()
        } else {
            baseAPIClient = URLSessionAPIClient(baseURL: Config.apiBaseURL) {
                authRepositoryBox.repository?.currentSession?.accessToken
            }
        }

        let authRepositoryImpl = AuthRepositoryImpl(apiClient: baseAPIClient)
        authRepositoryBox.repository = authRepositoryImpl
        authRepository = authRepositoryImpl

        apiClient = AuthenticatingAPIClient(wrapping: baseAPIClient, authRepository: authRepositoryImpl)

        creditRepository = CreditRepositoryImpl(apiClient: apiClient, localDataSource: localDataSource)
        transactionRepository = TransactionRepositoryImpl(apiClient: apiClient, localDataSource: localDataSource)
        userRepository = UserRepositoryImpl(apiClient: apiClient)
        cardRepository = CardRepositoryImpl(apiClient: apiClient)
        statementRepository = StatementRepositoryImpl(apiClient: apiClient)
        disputeRepository = DisputeRepositoryImpl(apiClient: apiClient)

        creditApplicationOutbox = CreditApplicationOutbox(localDataSource: localDataSource, creditRepository: creditRepository)

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
        fetchCardsUseCase = FetchCardsUseCase(cardRepository: cardRepository)
        setCardStatusUseCase = SetCardStatusUseCase(cardRepository: cardRepository)
        updateCardSpendingLimitUseCase = UpdateCardSpendingLimitUseCase(cardRepository: cardRepository)
        revealCardDetailsUseCase = RevealCardDetailsUseCase(cardRepository: cardRepository)
        fetchStatementsUseCase = FetchStatementsUseCase(statementRepository: statementRepository)
        downloadStatementUseCase = DownloadStatementUseCase(statementRepository: statementRepository)
        fetchDisputesUseCase = FetchDisputesUseCase(disputeRepository: disputeRepository)
        fileDisputeUseCase = FileDisputeUseCase(disputeRepository: disputeRepository)
    }
}
