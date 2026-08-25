import SwiftUI

struct TransactionsView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: RepaymentsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Activity")
            .task {
                if viewModel == nil {
                    viewModel = RepaymentsViewModel(
                        fetchCreditAccountsUseCase: dependencies.fetchCreditAccountsUseCase,
                        fetchTransactionsUseCase: dependencies.fetchTransactionsUseCase,
                        fetchRepaymentScheduleUseCase: dependencies.fetchRepaymentScheduleUseCase
                    )
                }
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: RepaymentsViewModel) -> some View {
        if viewModel.isLoading && viewModel.transactions.isEmpty {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) { Task { await viewModel.load() } }
        } else {
            List {
                Section {
                    NavigationLink {
                        RepaymentScheduleView(installments: viewModel.installments)
                    } label: {
                        Label("Repayment Schedule", systemImage: "calendar")
                    }
                }
                Section("Transactions") {
                    if viewModel.transactions.isEmpty {
                        Text("No transactions yet.").foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.transactions) { transaction in
                            TransactionActivityRow(transaction: transaction)
                        }
                    }
                }
            }
            .refreshable { await viewModel.load() }
        }
    }
}

private struct TransactionActivityRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                Text(transaction.date, style: .date).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(CurrencyFormatter.string(from: transaction.amount, currencyCode: transaction.currency))
                .foregroundStyle(transaction.type == .credit ? DesignSystem.Colors.success : .primary)
        }
    }
}
