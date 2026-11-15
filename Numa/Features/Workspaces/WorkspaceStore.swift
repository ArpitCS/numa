import Foundation

struct WorkspaceRecord: Codable, Equatable {
    let id: UUID
    let name: String
}

protocol WorkspaceStore {
    func load() -> (workspaces: [WorkspaceRecord], selectedID: UUID?)
    func save(workspaces: [WorkspaceRecord], selectedID: UUID)
}

final class UserDefaultsWorkspaceStore: WorkspaceStore {
    private let defaults: UserDefaults
    private let workspacesKey = "workspaceRecords"
    private let selectedWorkspaceKey = "selectedWorkspaceID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> (workspaces: [WorkspaceRecord], selectedID: UUID?) {
        let decoder = JSONDecoder()
        let records = defaults.data(forKey: workspacesKey)
            .flatMap { try? decoder.decode([WorkspaceRecord].self, from: $0) } ?? []
        let selectedID = defaults.string(forKey: selectedWorkspaceKey).flatMap(UUID.init)
        return (records, selectedID)
    }

    func save(workspaces: [WorkspaceRecord], selectedID: UUID) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(workspaces) else {
            return
        }
        defaults.set(data, forKey: workspacesKey)
        defaults.set(selectedID.uuidString, forKey: selectedWorkspaceKey)
    }
}
