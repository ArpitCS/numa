import XCTest
@testable import Numa

final class AddressParserTests: XCTestCase {
    func testAddsHTTPSchemeWhenInputHasNoScheme() {
        XCTAssertEqual(
            AddressParser.url(from: "example.com")?.absoluteString,
            "https://example.com"
        )
    }

    func testPreservesExistingScheme() {
        XCTAssertEqual(
            AddressParser.url(from: "http://example.com")?.absoluteString,
            "http://example.com"
        )
    }

    func testRejectsBlankInput() {
        XCTAssertNil(AddressParser.url(from: "   "))
    }
}
