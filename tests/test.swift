import XCTest

class MyTests : XCTestCase {
  func testAdd() {
    let result = add(a: 3, b:5)
    XCTAssertEqual(result, 8, "")
  }

  func testAddFail() {
    XCTAssertTrue(false, "lol")
  }

  func testThrows() {
    XCTAssertThrowsError(NSException.raise(NSExceptionName.genericException, format:"#yolo", arguments: getVaList([])))
  }
}

