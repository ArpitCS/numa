import XCTest

final class LaunchTests: XCTestCase {
    func testMainWindowContentAppears() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Workspaces"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["addressField"].exists)
        XCTAssertTrue(app.buttons["New Tab"].exists)
        XCTAssertTrue(app.buttons["New Workspace"].exists)
    }

    func testCanCreateAndCloseTab() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["New Tab"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["New Tab"].firstMatch.click()
        XCTAssertTrue(app.buttons["tab-2"].waitForExistence(timeout: 5))

        app.buttons["Close Tab"].firstMatch.click()
        XCTAssertTrue(app.buttons["tab-2"].waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab-1"].exists)
    }

    func testCanSwitchTabs() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["New Tab"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["New Tab"].firstMatch.click()
        XCTAssertTrue(app.buttons["tab-2"].waitForExistence(timeout: 5))

        app.buttons["tab-1"].click()
        XCTAssertTrue(app.textFields["addressField"].exists)
    }

    func testCanCreateAndSelectWorkspace() {
        let app = XCUIApplication()
        app.launch()

        let initialWorkspaceName = app.staticTexts["selectedWorkspaceName"]
        XCTAssertTrue(initialWorkspaceName.waitForExistence(timeout: 5))
        let initialValue = initialWorkspaceName.value as? String

        XCTAssertTrue(app.buttons["New Workspace"].waitForExistence(timeout: 5))
        app.buttons["New Workspace"].click()

        let updatedWorkspaceName = app.staticTexts["selectedWorkspaceName"]
        XCTAssertTrue(updatedWorkspaceName.waitForExistence(timeout: 5))
        XCTAssertNotEqual(updatedWorkspaceName.value as? String, initialValue)
    }
}
