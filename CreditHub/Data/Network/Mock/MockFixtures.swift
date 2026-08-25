import Foundation

/// Canned data returned by `MockAPIClient` so the app is fully runnable without a backend.
enum MockFixtures {
    static let user = UserDTO(
        id: "usr_1001",
        fullName: "Alex Morgan",
        email: "alex.morgan@example.com",
        phoneNumber: "+1 555-0142",
        memberSince: Date(timeIntervalSince1970: 1_580_000_000)
    )

    static let session = AuthSessionDTO(
        accessToken: "mock-access-token",
        refreshToken: "mock-refresh-token",
        expiresAt: Date().addingTimeInterval(3600),
        user: user
    )

    static let accounts: [CreditAccountDTO] = [
        CreditAccountDTO(
            id: "acct_1",
            productName: "Platinum Rewards Credit Line",
            accountNumberMasked: "•••• 4821",
            creditLimit: 15000,
            availableCredit: 9250.50,
            currentBalance: 5749.50,
            currency: "USD",
            status: "active"
        ),
        CreditAccountDTO(
            id: "acct_2",
            productName: "Small Business Credit Line",
            accountNumberMasked: "•••• 7734",
            creditLimit: 50000,
            availableCredit: 42000,
            currentBalance: 8000,
            currency: "USD",
            status: "active"
        )
    ]

    static let applications: [CreditApplicationDTO] = [
        CreditApplicationDTO(
            id: "app_1",
            productName: "Premium Travel Credit Line",
            requestedAmount: 20000,
            currency: "USD",
            status: "underReview",
            submittedAt: Date().addingTimeInterval(-86_400 * 3)
        )
    ]

    static let transactions: [TransactionDTO] = [
        TransactionDTO(id: "txn_1", accountId: "acct_1", description: "Grocery Mart", amount: 84.20, currency: "USD", date: Date().addingTimeInterval(-3600 * 5), type: "debit", category: "Groceries"),
        TransactionDTO(id: "txn_2", accountId: "acct_1", description: "Payment Received", amount: 500, currency: "USD", date: Date().addingTimeInterval(-3600 * 30), type: "credit", category: "Payment"),
        TransactionDTO(id: "txn_3", accountId: "acct_1", description: "Airline Booking", amount: 412.75, currency: "USD", date: Date().addingTimeInterval(-3600 * 50), type: "debit", category: "Travel")
    ]

    static let repaymentSchedule: [RepaymentInstallmentDTO] = [
        RepaymentInstallmentDTO(id: "rpm_1", accountId: "acct_1", dueDate: Date().addingTimeInterval(86_400 * 5), amountDue: 250, currency: "USD", status: "upcoming"),
        RepaymentInstallmentDTO(id: "rpm_2", accountId: "acct_1", dueDate: Date().addingTimeInterval(-86_400 * 25), amountDue: 250, currency: "USD", status: "paid")
    ]
}
