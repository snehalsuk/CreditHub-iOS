import SwiftUI

struct DashboardView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(for: viewModel.state, viewModel: viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Dashboard")
            .task {
                if viewModel == nil {
                    viewModel = DashboardViewModel(fetchDashboardUseCase: dependencies.fetchDashboardUseCase)
                }
                await viewModel?.load()
            }
        }
        .privacyProtected()
    }

    @ViewBuilder
    private func content(for state: DashboardViewModel.State, viewModel: DashboardViewModel) -> some View {
        switch state {
        case .loading:
            LoadingView()
        case .failed(let error):
            ErrorStateView(error: error) {
                Task { await viewModel.load() }
            }
        case .loaded(let accounts, let recentTransactions):
            List {
                Section("Your Credit Accounts") {
                    ForEach(accounts) { account in
                        CreditAccountRow(account: account)
                    }
                }
                Section("Recent Activity") {
                    if recentTransactions.isEmpty {
                        Text("No recent transactions.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
            }
            .refreshable { await viewModel.load() }
        }
    }
}

private struct CreditAccountRow: View {
    let account: CreditAccount

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(account.productName).font(DesignSystem.Typography.headline)
            Text(account.accountNumberMasked).font(.caption).foregroundStyle(.secondary)
            HStack {
                Text("Available")
                Spacer()
                Text(CurrencyFormatter.string(from: account.availableCredit, currencyCode: account.currency))
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                Text(transaction.category).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(CurrencyFormatter.string(from: transaction.amount, currencyCode: transaction.currency))
                .foregroundStyle(transaction.type == .credit ? DesignSystem.Colors.success : .primary)
        }
    }
}
