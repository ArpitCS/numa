import Foundation
import Observation

@MainActor
@Observable
final class WorkspaceManager {
    private let engine: WebKitBrowserEngine

    private(set) var workspaces: [Workspace]
    var selectedWorkspaceID: Workspace.ID

    init(engine: WebKitBrowserEngine) {
        self.engine = engine
        let workspace = Workspace(
            name: "Personal",
            tabManager: TabManager(engine: engine)
        )
        workspaces = [workspace]
        selectedWorkspaceID = workspace.id
    }

    var selectedWorkspace: Workspace? {
        workspaces.first { $0.id == selectedWorkspaceID }
    }

    @discardableResult
    func createWorkspace(named name: String) -> Workspace? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return nil
        }

        let workspace = Workspace(
            name: trimmedName,
            tabManager: TabManager(engine: engine)
        )
        workspaces.append(workspace)
        selectedWorkspaceID = workspace.id
        return workspace
    }

    func selectWorkspace(_ id: Workspace.ID) {
        guard workspaces.contains(where: { $0.id == id }) else {
            return
        }
        selectedWorkspaceID = id
    }

    func renameWorkspace(_ id: Workspace.ID, to name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let workspace = workspaces.first(where: { $0.id == id })
        else {
            return false
        }

        workspace.name = trimmedName
        return true
    }

    func deleteWorkspace(_ id: Workspace.ID) -> Bool {
        guard workspaces.count > 1,
              let index = workspaces.firstIndex(where: { $0.id == id })
        else {
            return false
        }

        workspaces.remove(at: index)
        if selectedWorkspaceID == id {
            selectedWorkspaceID = workspaces[min(index, workspaces.count - 1)].id
        }
        return true
    }
}
