import SwiftUI

struct LoginView: View {
    @Environment(\.session) private var session
    @State private var viewModel: LoginViewModel

    init(loginUseCase: LoginUseCase) {
        _viewModel = State(initialValue: LoginViewModel(loginUseCase: loginUseCase))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(DesignSystem.Colors.primary)
                Text("CreditHub")
                    .font(DesignSystem.Typography.title)
                Text("Sign in to manage your credit accounts")
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: DesignSystem.Spacing.md) {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(DesignSystem.Colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 10))

                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .padding()
                    .background(DesignSystem.Colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 10))

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.danger)
                }

                Button {
                    Task {
                        if await viewModel.login() {
                            session.isAuthenticated = true
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.white).frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.canSubmit)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)

            Spacer()

            Text("Demo build — any email and password signs in against the mock API.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
    }
}
