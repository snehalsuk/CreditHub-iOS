import SwiftUI

struct DisputeListView: View {
    @Bindable var viewModel: DisputesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.disputes.isEmpty {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.disputes.isEmpty {
                ErrorStateView(error: errorMessage) { Task { await viewModel.load() } }
            } else if viewModel.disputes.isEmpty {
                ContentUnavailableView("No Disputes", systemImage: "exclamationmark.bubble", description: Text("Disputes you file on a transaction will appear here."))
            } else {
                List(viewModel.disputes) { dispute in
                    DisputeRow(dispute: dispute)
                }
                .refreshable { await viewModel.load() }
            }
        }
        .navigationTitle("Disputes")
        .task { await viewModel.load() }
    }
}

private struct DisputeRow: View {
    let dispute: Dispute

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(dispute.reason).font(DesignSystem.Typography.headline)
            HStack {
                Text(dispute.createdAt, style: .date)
                Spacer()
                Text(statusLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(statusColor)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    private var statusLabel: String {
        switch dispute.status {
        case .open: return "Open"
        case .underReview: return "Under Review"
        case .resolved: return "Resolved"
        }
    }

    private var statusColor: Color {
        switch dispute.status {
        case .open, .underReview: return DesignSystem.Colors.warning
        case .resolved: return DesignSystem.Colors.success
        }
    }
}
