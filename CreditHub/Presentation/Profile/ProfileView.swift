import SwiftUI

struct ProfileView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.session) private var session
    @State private var viewModel: ProfileViewModel?
    @State private var disputesViewModel: DisputesViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Profile")
            .task {
                if viewModel == nil {
                    viewModel = ProfileViewModel(
                        fetchProfileUseCase: dependencies.fetchProfileUseCase,
                        updateBiometricPreferenceUseCase: dependencies.updateBiometricPreferenceUseCase,
                        logoutUseCase: dependencies.logoutUseCase
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
        }
        .privacyProtected()
    }

    @ViewBuilder
    private func content(_ viewModel: ProfileViewModel) -> some View {
        if viewModel.isLoading && viewModel.user == nil {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.user == nil {
            ErrorStateView(error: errorMessage) { Task { await viewModel.load() } }
        } else {
            List {
                if let user = viewModel.user {
                    Section {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(user.fullName).font(DesignSystem.Typography.headline)
                            Text(user.email).font(.subheadline).foregroundStyle(.secondary)
                            Text(user.phoneNumber).font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .accessibilityElement(children: .combine)
                    }
                }

                Section("Security") {
                    Toggle("Biometric Unlock", isOn: Binding(
                        get: { viewModel.isBiometricEnabled },
                        set: { newValue in Task { await viewModel.setBiometricEnabled(newValue) } }
                    ))
                    .disabled(viewModel.isUpdatingPreference)
                }

                Section("Documents & Support") {
                    NavigationLink("Statements") {
                        StatementsListView()
                    }
                    if let disputesViewModel {
                        NavigationLink("Disputes") {
                            DisputeListView(viewModel: disputesViewModel)
                        }
                    }
                    NavigationLink("Help & Support") {
                        SupportView()
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        Task {
                            await viewModel.logout()
                            session.isAuthenticated = false
                            session.isUnlocked = false
                        }
                    }
                }
            }
        }
    }
}
