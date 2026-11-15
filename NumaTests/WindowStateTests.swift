import XCTest
@testable import Numa

@MainActor
final class WindowStateTests: XCTestCase {
    func testNewWindowStartsWithVisibleSidebarAndNoSelectedWorkspace() {
        let state = WindowState()

        XCTAssertEqual(state.sidebarVisibility, .all)
        XCTAssertNil(state.selectedWorkspaceID)
    }
}
