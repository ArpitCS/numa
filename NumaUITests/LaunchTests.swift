import XCTest

final class LaunchTests: XCTestCase {
    func testMainWindowContentAppears() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Sidebar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["addressField"].exists)
    }
}
