import SwiftUI

struct CardDetailView: View {
    let card: Card
    @Bindable var viewModel: CardsViewModel
    let biometricAuth: BiometricAuthManager

    @State private var revealTrigger = false
    @State private var spendingLimitText: String

    init(card: Card, viewModel: CardsViewModel, biometricAuth: BiometricAuthManager) {
        self.card = card
        self.viewModel = viewModel
        self.biometricAuth = biometricAuth
        _spendingLimitText = State(initialValue: NSDecimalNumber(decimal: card.spendingLimit).stringValue)
    }

    private var currentCard: Card {
        viewModel.cards.first(where: { $0.id == card.id }) ?? card
    }

    var body: some View {
        Form {
            Section("Card") {
                LabeledContent("Network", value: currentCard.network.rawValue.capitalized)
                LabeledContent("Type", value: currentCard.cardType == .virtual ? "Virtual" : "Physical")
                LabeledContent("Number", value: "•••• •••• •••• \(currentCard.lastFourDigits)")
            }

            Section("Card Number & CVV") {
                if let details = viewModel.revealedDetails[card.id] {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(details.cardNumber).font(.system(.body, design: .monospaced))
                        Text("Exp \(details.expiryMonth)/\(details.expiryYear) · CVV \(details.cvv)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    Button("Hide", role: .destructive) {
                        viewModel.hideDetails(for: card)
                    }
                } else {
                    Button("Reveal with Face ID") {
                        revealTrigger = true
                    }
                }
            }

            Section("Controls") {
                Button(currentCard.status == .frozen ? "Unfreeze Card" : "Freeze Card") {
                    Task { await viewModel.toggleFreeze(currentCard) }
                }
                .foregroundStyle(currentCard.status == .frozen ? DesignSystem.Colors.success : DesignSystem.Colors.warning)
            }

            Section("Spending Limit") {
                TextField("Spending limit", text: $spendingLimitText)
                    .keyboardType(.decimalPad)
                Button("Update Limit") {
                    guard let newLimit = Decimal(string: spendingLimitText) else { return }
                    Task { await viewModel.updateSpendingLimit(currentCard, to: newLimit) }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage.message).foregroundStyle(DesignSystem.Colors.danger)
            }
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .stepUpAuthRequired(trigger: $revealTrigger, reason: "Verify it's you to view your full card number.", biometricAuth: biometricAuth) {
            Task { await viewModel.revealDetails(for: card) }
        }
    }
}
