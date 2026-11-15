import XCTest
@testable import Numa

@MainActor
final class TabManagerTests: XCTestCase {
    func testStartsWithOneSelectedTab() {
        let manager = TabManager(engine: WebKitBrowserEngine())

        XCTAssertEqual(manager.tabs.count, 1)
        XCTAssertEqual(manager.selectedTabID, manager.tabs.first?.id)
    }

    func testNewTabSelectsNewTab() {
        let manager = TabManager(engine: WebKitBrowserEngine())
        let firstTab = try! XCTUnwrap(manager.tabs.first)

        let newTab = manager.newTab()

        XCTAssertEqual(manager.tabs.map(\.id), [firstTab.id, newTab.id])
        XCTAssertEqual(manager.selectedTabID, newTab.id)
    }

    func testClosingSelectedTabSelectsAdjacentTab() {
        let manager = TabManager(engine: WebKitBrowserEngine())
        let firstTab = try! XCTUnwrap(manager.tabs.first)
        let secondTab = manager.newTab()

        manager.closeTab(secondTab.id)

        XCTAssertEqual(manager.tabs.map(\.id), [firstTab.id])
        XCTAssertEqual(manager.selectedTabID, firstTab.id)
    }

    func testClosingLastTabCreatesReplacement() {
        let manager = TabManager(engine: WebKitBrowserEngine())
        let tabID = try! XCTUnwrap(manager.tabs.first?.id)

        manager.closeTab(tabID)

        XCTAssertEqual(manager.tabs.count, 1)
        XCTAssertNotEqual(manager.tabs.first?.id, tabID)
        XCTAssertEqual(manager.selectedTabID, manager.tabs.first?.id)
    }
}
