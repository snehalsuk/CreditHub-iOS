import MessageUI
import SwiftUI

struct SupportView: View {
    @State private var isShowingMailComposer = false
    @State private var mailResult: Result<MFMailComposeResult, Error>?

    private let faqs: [(question: String, answer: String)] = [
        ("How do I freeze a card?", "Go to Cards, select a card, and tap Freeze Card. You can unfreeze it at any time."),
        ("How long do disputes take to resolve?", "Most disputes are reviewed within 5-10 business days. Track status under Profile > Disputes."),
        ("How do I download a statement?", "Go to Profile > Statements, select a period, and the document opens in-app.")
    ]

    var body: some View {
        List {
            Section("Frequently Asked Questions") {
                ForEach(faqs, id: \.question) { faq in
                    DisclosureGroup(faq.question) {
                        Text(faq.answer)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section("Contact Us") {
                Button {
                    isShowingMailComposer = true
                } label: {
                    Label("Email Support", systemImage: "envelope")
                }
                .disabled(!MFMailComposeViewController.canSendMail())
            }
        }
        .navigationTitle("Support")
        .sheet(isPresented: $isShowingMailComposer) {
            MailComposerView(result: $mailResult)
        }
    }
}

private struct MailComposerView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(result: $result, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(["support@credithub.example.com"])
        controller.setSubject("CreditHub Support Request")
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var result: Result<MFMailComposeResult, Error>?
        let dismiss: DismissAction

        init(result: Binding<Result<MFMailComposeResult, Error>?>, dismiss: DismissAction) {
            _result = result
            self.dismiss = dismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            self.result = error.map(Result.failure) ?? .success(result)
            dismiss()
        }
    }
}
