import Foundation
import Observation

@MainActor
@Observable
final class WorkspaceManager {
    private let engine: WebKitBrowserEngine
    private let store: WorkspaceStore

    private(set) var workspaces: [Workspace]
    var selectedWorkspaceID: Workspace.ID

    init(engine: WebKitBrowserEngine, store: WorkspaceStore) {
        self.engine = engine
        self.store = store

        let savedState = store.load()
        let records = savedState.workspaces.isEmpty
            ? [WorkspaceRecord(id: UUID(), name: "Personal")]
            : savedState.workspaces
        let restoredWorkspaces = records.map {
            Workspace(
                id: $0.id,
                name: $0.name,
                tabManager: TabManager(engine: engine)
            )
        }
        workspaces = restoredWorkspaces
        let restoredSelection = savedState.selectedID.flatMap { id in
            restoredWorkspaces.contains { $0.id == id } ? id : nil
        }
        selectedWorkspaceID = restoredSelection ?? restoredWorkspaces[0].id
        persist()
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
        persist()
        return workspace
    }

    func selectWorkspace(_ id: Workspace.ID) {
        guard workspaces.contains(where: { $0.id == id }) else {
            return
        }
        selectedWorkspaceID = id
        persist()
    }

    func renameWorkspace(_ id: Workspace.ID, to name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let workspace = workspaces.first(where: { $0.id == id })
        else {
            return false
        }

        workspace.name = trimmedName
        persist()
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
        persist()
        return true
    }

    private func persist() {
        store.save(
            workspaces: workspaces.map { WorkspaceRecord(id: $0.id, name: $0.name) },
            selectedID: selectedWorkspaceID
        )
    }
}
