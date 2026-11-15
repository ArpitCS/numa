import XCTest
@testable import Numa

@MainActor
final class TabManagerTests: XCTestCase {
    func testTabShortcutsOnlySupportTheFirstNineTabs() {
        XCTAssertEqual(TabShortcut.character(for: 0), "1")
        XCTAssertEqual(TabShortcut.character(for: 8), "9")
        XCTAssertNil(TabShortcut.character(for: 9))
    }

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

    func testSelectTabByIndex() {
        let manager = TabManager(engine: WebKitBrowserEngine())
        let secondTab = manager.newTab(select: false)

        manager.selectTab(at: 1)

        XCTAssertEqual(manager.selectedTabID, secondTab.id)
    }

    func testSelectTabByIndexIgnoresInvalidIndex() {
        let manager = TabManager(engine: WebKitBrowserEngine())
        let initialSelection = manager.selectedTabID

        manager.selectTab(at: 2)

        XCTAssertEqual(manager.selectedTabID, initialSelection)
    }
}
