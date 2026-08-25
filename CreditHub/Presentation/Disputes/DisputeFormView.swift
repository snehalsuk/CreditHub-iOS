import SwiftUI

struct DisputeFormView: View {
    let transaction: Transaction
    @Bindable var viewModel: DisputesViewModel
    let biometricAuth: BiometricAuthManager
    @Binding var isPresented: Bool

    @State private var reason = ""
    @State private var stepUpTrigger = false

    private let commonReasons = [
        "I don't recognize this charge",
        "I was charged the wrong amount",
        "I was charged more than once",
        "I canceled this but was still charged"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction") {
                    LabeledContent(transaction.description, value: CurrencyFormatter.string(from: transaction.amount, currencyCode: transaction.currency))
                }
                Section("Reason") {
                    Picker("Reason", selection: $reason) {
                        Text("Select a reason").tag("")
                        ForEach(commonReasons, id: \.self) { Text($0).tag($0) }
                    }
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage.message).foregroundStyle(DesignSystem.Colors.danger)
                }
            }
            .navigationTitle("File a Dispute")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        stepUpTrigger = true
                    }
                    .disabled(reason.isEmpty || viewModel.isSubmitting)
                }
            }
        }
        .stepUpAuthRequired(trigger: $stepUpTrigger, reason: "Verify it's you to file this dispute.", biometricAuth: biometricAuth) {
            Task {
                if await viewModel.fileDispute(transactionId: transaction.id, reason: reason) {
                    isPresented = false
                }
            }
        }
    }
}
