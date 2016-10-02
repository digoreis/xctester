import Darwin

func my_exit(code: Int) {
    exit(Int32(code))
}

let success = XCTestRunAll()
my_exit(code: (success ? 0 : 65))
