import Foundation
import Observation

@MainActor
@Observable
final class Workspace: Identifiable {
    let id: UUID
    var name: String
    let tabManager: TabManager

    init(id: UUID = UUID(), name: String, tabManager: TabManager) {
        self.id = id
        self.name = name
        self.tabManager = tabManager
    }
}
