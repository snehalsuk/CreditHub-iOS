import SwiftUI

struct CardsView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: CardsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Cards")
            .task {
                if viewModel == nil {
                    viewModel = CardsViewModel(
                        fetchCreditAccountsUseCase: dependencies.fetchCreditAccountsUseCase,
                        fetchCardsUseCase: dependencies.fetchCardsUseCase,
                        setCardStatusUseCase: dependencies.setCardStatusUseCase,
                        updateCardSpendingLimitUseCase: dependencies.updateCardSpendingLimitUseCase,
                        revealCardDetailsUseCase: dependencies.revealCardDetailsUseCase
                    )
                }
                await viewModel?.load()
            }
        }
        .privacyProtected()
    }

    @ViewBuilder
    private func content(_ viewModel: CardsViewModel) -> some View {
        if viewModel.isLoading && viewModel.cards.isEmpty {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.cards.isEmpty {
            ErrorStateView(error: errorMessage) { Task { await viewModel.load() } }
        } else if viewModel.cards.isEmpty {
            ContentUnavailableView("No Cards", systemImage: "creditcard", description: Text("Cards linked to your accounts will appear here."))
        } else {
            List(viewModel.cards) { card in
                NavigationLink {
                    CardDetailView(card: card, viewModel: viewModel, biometricAuth: dependencies.biometricAuth)
                } label: {
                    CardRow(card: card)
                }
            }
            .refreshable { await viewModel.load() }
        }
    }
}

private struct CardRow: View {
    let card: Card

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: card.cardType == .virtual ? "wallet.pass" : "creditcard.fill")
                .font(.title2)
                .foregroundStyle(card.status == .active ? DesignSystem.Colors.primary : .secondary)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("\(card.network.rawValue.capitalized) •••• \(card.lastFourDigits)")
                    .font(DesignSystem.Typography.headline)
                Text(card.cardType == .virtual ? "Virtual" : "Physical")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if card.status == .frozen {
                Label("Frozen", systemImage: "snowflake")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DesignSystem.Colors.warning)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
