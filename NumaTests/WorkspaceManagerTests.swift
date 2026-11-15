import XCTest
@testable import Numa

@MainActor
final class WorkspaceManagerTests: XCTestCase {
    private func makeStore() -> InMemoryWorkspaceStore {
        InMemoryWorkspaceStore()
    }

    func testStartsWithPersonalWorkspace() {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: makeStore())

        XCTAssertEqual(manager.workspaces.count, 1)
        XCTAssertEqual(manager.selectedWorkspace?.name, "Personal")
    }

    func testCreatingWorkspaceSelectsIt() {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: makeStore())

        let workspace = manager.createWorkspace(named: "Work")

        XCTAssertEqual(workspace?.name, "Work")
        XCTAssertEqual(manager.selectedWorkspaceID, workspace?.id)
        XCTAssertEqual(manager.workspaces.count, 2)
    }

    func testWorkspaceChangesAreRestoredFromStore() throws {
        let store = makeStore()
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: store)
        let workspace = try XCTUnwrap(manager.createWorkspace(named: "Work"))
        XCTAssertTrue(manager.renameWorkspace(workspace.id, to: "Development"))

        let restoredManager = WorkspaceManager(engine: WebKitBrowserEngine(), store: store)

        XCTAssertEqual(restoredManager.workspaces.map(\.name), ["Personal", "Development"])
        XCTAssertEqual(restoredManager.selectedWorkspaceID, workspace.id)
    }

    func testRejectsBlankWorkspaceNames() {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: makeStore())

        XCTAssertNil(manager.createWorkspace(named: "   "))
        XCTAssertEqual(manager.workspaces.count, 1)
    }

    func testWorkspacesHaveIndependentTabs() throws {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: makeStore())
        let personal = try XCTUnwrap(manager.selectedWorkspace)
        let work = try XCTUnwrap(manager.createWorkspace(named: "Work"))

        work.tabManager.newTab()

        XCTAssertEqual(personal.tabManager.tabs.count, 1)
        XCTAssertEqual(work.tabManager.tabs.count, 2)
    }

    func testCannotDeleteLastWorkspace() throws {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: makeStore())
        let workspaceID = try XCTUnwrap(manager.workspaces.first?.id)

        XCTAssertFalse(manager.deleteWorkspace(workspaceID))
        XCTAssertEqual(manager.workspaces.count, 1)
    }

    func testDeletingSelectedWorkspaceSelectsNeighbor() throws {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine(), store: makeStore())
        let first = try XCTUnwrap(manager.workspaces.first)
        let second = try XCTUnwrap(manager.createWorkspace(named: "Work"))

        XCTAssertTrue(manager.deleteWorkspace(second.id))
        XCTAssertEqual(manager.selectedWorkspaceID, first.id)
    }
}

private final class InMemoryWorkspaceStore: WorkspaceStore {
    var records: [WorkspaceRecord] = []
    var selectedID: UUID?

    func load() -> (workspaces: [WorkspaceRecord], selectedID: UUID?) {
        (records, selectedID)
    }

    func save(workspaces: [WorkspaceRecord], selectedID: UUID) {
        records = workspaces
        self.selectedID = selectedID
    }
}
