import SwiftUI

struct ApplicationListView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: CreditApplicationsViewModel?
    @State private var showingNewApplication = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    listContent(viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Applications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewApplication = true
                    } label: {
                        Label("New Application", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewApplication) {
                if let viewModel {
                    NewApplicationView(viewModel: viewModel, isPresented: $showingNewApplication)
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = CreditApplicationsViewModel(
                        fetchCreditApplicationsUseCase: dependencies.fetchCreditApplicationsUseCase,
                        submitCreditApplicationUseCase: dependencies.submitCreditApplicationUseCase,
                        creditApplicationOutbox: dependencies.creditApplicationOutbox,
                        networkMonitor: dependencies.networkMonitor
                    )
                }
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private func listContent(_ viewModel: CreditApplicationsViewModel) -> some View {
        VStack(spacing: 0) {
            if let notice = viewModel.queuedOfflineNotice {
                Label(notice, systemImage: "tray.and.arrow.up")
                    .font(.footnote.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.warning)
                    .foregroundStyle(.white)
                    .accessibilityElement(children: .combine)
            }

            if viewModel.isLoading && viewModel.applications.isEmpty {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.applications.isEmpty {
                ErrorStateView(error: errorMessage) { Task { await viewModel.load() } }
            } else if viewModel.applications.isEmpty {
                ContentUnavailableView("No Applications Yet", systemImage: "doc.text", description: Text("Tap + to apply for a new credit product."))
            } else {
                List(viewModel.applications) { application in
                    ApplicationRow(application: application)
                }
                .refreshable { await viewModel.load() }
            }
        }
    }
}

private struct ApplicationRow: View {
    let application: CreditApplication

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(application.productName).font(DesignSystem.Typography.headline)
            HStack {
                Text(CurrencyFormatter.string(from: application.requestedAmount, currencyCode: application.currency))
                Spacer()
                StatusBadge(status: application.status)
            }
            .font(.subheadline)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}

private struct StatusBadge: View {
    let status: CreditApplicationStatus

    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
            .accessibilityLabel("Status: \(label)")
    }

    private var label: String {
        switch status {
        case .draft: return "Draft"
        case .submitted: return "Submitted"
        case .underReview: return "Under Review"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        }
    }

    private var color: Color {
        switch status {
        case .draft: return .gray
        case .submitted, .underReview: return DesignSystem.Colors.warning
        case .approved: return DesignSystem.Colors.success
        case .rejected: return DesignSystem.Colors.danger
        }
    }
}
