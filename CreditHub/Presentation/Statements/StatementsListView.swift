import SwiftUI

/// Pushed from `ProfileView`'s existing `NavigationStack` — deliberately doesn't wrap itself in
/// another `NavigationStack`.
struct StatementsListView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: StatementsViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                LoadingView()
            }
        }
        .navigationTitle("Statements")
        .task {
            if viewModel == nil {
                viewModel = StatementsViewModel(
                    fetchCreditAccountsUseCase: dependencies.fetchCreditAccountsUseCase,
                    fetchStatementsUseCase: dependencies.fetchStatementsUseCase,
                    downloadStatementUseCase: dependencies.downloadStatementUseCase
                )
            }
            await viewModel?.load()
        }
    }

    @ViewBuilder
    private func content(_ viewModel: StatementsViewModel) -> some View {
        if viewModel.isLoading && viewModel.statements.isEmpty {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.statements.isEmpty {
            ErrorStateView(error: errorMessage) { Task { await viewModel.load() } }
        } else if viewModel.statements.isEmpty {
            ContentUnavailableView("No Statements", systemImage: "doc.text", description: Text("Your monthly statements will appear here."))
        } else {
            List(viewModel.statements) { statement in
                NavigationLink {
                    StatementViewerView(statement: statement, viewModel: viewModel)
                } label: {
                    StatementRow(statement: statement)
                }
            }
            .refreshable { await viewModel.load() }
        }
    }
}

private struct StatementRow: View {
    let statement: Statement

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(statement.periodEnd, format: .dateTime.month(.wide).year())
                .font(DesignSystem.Typography.headline)
            Text("Issued \(statement.issuedDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
