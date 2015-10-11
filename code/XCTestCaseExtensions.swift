import ObjectiveC
import XCTest

var AssociatedObjectHandle: UInt8 = 0

class Failure : NSObject {
    let failureDescription: String!
    let filePath: String!
    let lineNumber: UInt
    let expected: Bool

    override var description: String {
        return self.failureDescription
    }

    init(description: String!, filePath: String!, lineNumber: UInt, expected: Bool) {
        failureDescription = description
        self.filePath = filePath
        self.lineNumber = lineNumber
        self.expected = expected
    }
}

extension NSTimeInterval {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

let recordFailure_block : @convention(block) (sself: XCTestCase, description: String!, filePath: String!, lineNumber: UInt, expected: Bool) -> Void = { (sself, description, filePath, lineNumber, expected) -> (Void) in
    if sself.records == nil {
        sself.records = [Failure]()
    }

    sself.records.append(Failure(description: description, filePath: filePath,
        lineNumber: lineNumber, expected: expected))
}

let recordUnexpectedFailure_block : @convention(block) (sself: XCTestCase, description: String!, exception: NSException!) -> Void = { (sself, description, exception) -> Void in
    if sself.records == nil {
        sself.records = [Failure]()
    }

    let truncatedDescription = String((description.characters.split() { $0 == "\n" }).first!)
    sself.records.append(Failure(description: truncatedDescription, filePath: nil, lineNumber: 0, expected: false))
}

class LolSwift: NSObject {
    override class func initialize() {
        let recordFailure_IMP = imp_implementationWithBlock(unsafeBitCast(recordFailure_block, AnyObject.self))
        let recordFailure_method = class_getInstanceMethod(XCTestCase.self, "recordFailureWithDescription:inFile:atLine:expected:")
        let _ = method_setImplementation(recordFailure_method, recordFailure_IMP)

        let recordUnexpectedFailure_IMP = imp_implementationWithBlock(unsafeBitCast(recordUnexpectedFailure_block, AnyObject.self))
        let recordUnexpectedFailure_method = class_getInstanceMethod(XCTestCase.self, "_recordUnexpectedFailureWithDescription:exception:")
        let _ = method_setImplementation(recordUnexpectedFailure_method, recordUnexpectedFailure_IMP)
    }
}

extension XCTestCase {
    var records: [Failure]! {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! [Failure]!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var success: Bool {
        return self.records == nil || self.records.count == 0
    }
}

/// Run all XCTest expectations and report the results to stdout
public func XCTestRunAll() -> Bool {
    let _ = LolSwift()

    let testSuite = XCTestSuite.defaultTestSuite()
    let suiteRun = XCTestSuiteRun(test: testSuite)
    testSuite.performTest(suiteRun)
    var failureCount = 0

    for testRun in suiteRun.testRuns {
        let suites = (testRun.test as! XCTestSuite).tests

        for suite in suites {
            let testCaseName = suite.name
            print(testCaseName + "\n")

            for test in (suite as! XCTestSuite).tests {
                let testCase = test as! XCTestCase

                let status = testCase.success ? "✅" : "❌"
                print("\(status)  \(testCase.name)")

                if (testCase.success) {
                    continue
                }

                failureCount++

                for failure in testCase.records {
                    print("\t\(failure)")
                }
            }
        }
    }

    let format = ".3"
    print("\n Executed \(suiteRun.executionCount) tests, with \(failureCount) failures (\(failureCount) unexpected) in \(suiteRun.testDuration.format(format)) seconds")

    return failureCount == 0
}
