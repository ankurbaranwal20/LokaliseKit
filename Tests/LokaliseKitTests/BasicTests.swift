import XCTest
@testable import LokaliseKit

final class BasicTests: XCTestCase {
    func testStringLocalizedAPICompiles() {
        _ = "hello_key".localized()
        XCTAssertTrue(true)
    }
}
