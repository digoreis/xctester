import XCTest

class MyTests : XCTestCase {
  func testAdd() {
    let result = add(3, 5)
    XCTAssertEqual(result, 8, "")
  }

  func testAddFail() {
    XCTAssertTrue(false, "lol")
  }
}

