import XCTest

final class LaunchTests: XCTestCase {
    func testMainWindowContentAppears() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Tabs"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["addressField"].exists)
        XCTAssertTrue(app.buttons["New Tab"].exists)
    }
}
