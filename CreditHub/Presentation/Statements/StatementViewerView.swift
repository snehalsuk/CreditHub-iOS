import PDFKit
import SwiftUI

struct StatementViewerView: View {
    let statement: Statement
    @Bindable var viewModel: StatementsViewModel

    @State private var document: PDFDocument?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let document {
                PDFKitRepresentableView(document: document)
            } else if isLoading {
                LoadingView()
            } else {
                ContentUnavailableView("Couldn't Load Statement", systemImage: "doc.text.magnifyingglass")
            }
        }
        .navigationTitle(statement.periodEnd.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            if let data = await viewModel.downloadDocument(for: statement) {
                document = PDFDocument(data: data)
            }
            isLoading = false
        }
    }
}

private struct PDFKitRepresentableView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = document
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
