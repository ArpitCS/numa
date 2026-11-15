import Foundation
import Observation

@MainActor
@Observable
final class BrowserTab: Identifiable {
    let id: UUID
    let viewModel: BrowserViewModel

    init(id: UUID = UUID(), viewModel: BrowserViewModel) {
        self.id = id
        self.viewModel = viewModel
    }

    var title: String {
        viewModel.page.title.isEmpty ? "New Tab" : viewModel.page.title
    }

    var address: String {
        viewModel.page.url?.absoluteString ?? ""
    }

    var isLoading: Bool {
        viewModel.page.isLoading
    }
}
