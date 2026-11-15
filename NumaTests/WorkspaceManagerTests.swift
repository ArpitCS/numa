import XCTest
@testable import Numa

@MainActor
final class WorkspaceManagerTests: XCTestCase {
    func testStartsWithPersonalWorkspace() {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine())

        XCTAssertEqual(manager.workspaces.count, 1)
        XCTAssertEqual(manager.selectedWorkspace?.name, "Personal")
    }

    func testCreatingWorkspaceSelectsIt() {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine())

        let workspace = manager.createWorkspace(named: "Work")

        XCTAssertEqual(workspace?.name, "Work")
        XCTAssertEqual(manager.selectedWorkspaceID, workspace?.id)
        XCTAssertEqual(manager.workspaces.count, 2)
    }

    func testRejectsBlankWorkspaceNames() {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine())

        XCTAssertNil(manager.createWorkspace(named: "   "))
        XCTAssertEqual(manager.workspaces.count, 1)
    }

    func testWorkspacesHaveIndependentTabs() throws {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine())
        let personal = try XCTUnwrap(manager.selectedWorkspace)
        let work = try XCTUnwrap(manager.createWorkspace(named: "Work"))

        work.tabManager.newTab()

        XCTAssertEqual(personal.tabManager.tabs.count, 1)
        XCTAssertEqual(work.tabManager.tabs.count, 2)
    }

    func testCannotDeleteLastWorkspace() throws {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine())
        let workspaceID = try XCTUnwrap(manager.workspaces.first?.id)

        XCTAssertFalse(manager.deleteWorkspace(workspaceID))
        XCTAssertEqual(manager.workspaces.count, 1)
    }

    func testDeletingSelectedWorkspaceSelectsNeighbor() throws {
        let manager = WorkspaceManager(engine: WebKitBrowserEngine())
        let first = try XCTUnwrap(manager.workspaces.first)
        let second = try XCTUnwrap(manager.createWorkspace(named: "Work"))

        XCTAssertTrue(manager.deleteWorkspace(second.id))
        XCTAssertEqual(manager.selectedWorkspaceID, first.id)
    }
}
