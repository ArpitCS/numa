import XCTest
@testable import Numa

final class AddressParserTests: XCTestCase {
    func testAddsHTTPSchemeWhenInputHasNoScheme() {
        XCTAssertEqual(
            AddressParser.destination(from: "example.com"),
            .url(URL(string: "https://example.com")!)
        )
    }

    func testPreservesExistingScheme() {
        XCTAssertEqual(
            AddressParser.destination(from: "http://example.com"),
            .url(URL(string: "http://example.com")!)
        )
    }

    func testRejectsBlankInput() {
        XCTAssertNil(AddressParser.destination(from: "   "))
    }

    func testRoutesQueriesToSearch() {
        XCTAssertEqual(
            AddressParser.destination(from: "swift concurrency"),
            .search(URL(string: "https://www.google.com/search?q=swift%20concurrency")!)
        )
    }
}
