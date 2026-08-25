import SwiftUI

struct NewApplicationView: View {
    @Bindable var viewModel: CreditApplicationsViewModel
    @Binding var isPresented: Bool

    private let products = ["Personal Credit Line", "Small Business Credit Line", "Premium Travel Credit Line"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    Picker("Product", selection: $viewModel.newProductName) {
                        ForEach(products, id: \.self) { Text($0) }
                    }
                }
                Section("Requested Amount") {
                    TextField("Amount (USD)", text: $viewModel.newRequestedAmount)
                        .keyboardType(.decimalPad)
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage.message).foregroundStyle(DesignSystem.Colors.danger)
                }
            }
            .navigationTitle("New Application")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task {
                            await viewModel.submitApplication()
                            if viewModel.errorMessage == nil {
                                isPresented = false
                            }
                        }
                    }
                    .disabled(viewModel.isSubmitting)
                }
            }
        }
    }
}
