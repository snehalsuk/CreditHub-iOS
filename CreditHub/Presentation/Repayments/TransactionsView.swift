import SwiftUI

struct TransactionsView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: RepaymentsViewModel?
    @State private var disputesViewModel: DisputesViewModel?
    @State private var disputingTransaction: Transaction?

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
                if disputesViewModel == nil {
                    disputesViewModel = DisputesViewModel(
                        fetchDisputesUseCase: dependencies.fetchDisputesUseCase,
                        fileDisputeUseCase: dependencies.fileDisputeUseCase
                    )
                }
                await viewModel?.load()
            }
            .sheet(item: $disputingTransaction) { transaction in
                if let disputesViewModel {
                    DisputeFormView(
                        transaction: transaction,
                        viewModel: disputesViewModel,
                        biometricAuth: dependencies.biometricAuth,
                        isPresented: Binding(
                            get: { disputingTransaction != nil },
                            set: { if !$0 { disputingTransaction = nil } }
                        )
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: RepaymentsViewModel) -> some View {
        if viewModel.isLoading && viewModel.transactions.isEmpty {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(error: errorMessage) { Task { await viewModel.load() } }
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
                                .swipeActions(edge: .trailing) {
                                    Button("Dispute") {
                                        disputingTransaction = transaction
                                    }
                                    .tint(DesignSystem.Colors.danger)
                                }
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
        .accessibilityElement(children: .combine)
    }
}
