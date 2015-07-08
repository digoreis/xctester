import Darwin

@noreturn func my_exit(code: Int) {
    exit(Int32(code))
}

let success = XCTestRunAll()
my_exit(success ? 0 : 65)
