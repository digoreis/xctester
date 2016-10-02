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

    init(description: String, filePath: String, lineNumber: UInt, expected: Bool) {
        failureDescription = description
        self.filePath = filePath
        self.lineNumber = lineNumber
        self.expected = expected
    }
}

extension TimeInterval {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

let recordFailure_block : @convention(block) (_ sself: XCTestCase, _ description: String, _ filePath: String, _ lineNumber: UInt, _ expected: Bool) -> Void = { (sself, description, filePath, lineNumber, expected) -> (Void) in
    if sself.records == nil {
        sself.records = [Failure]()
    }
    sself.records.append(Failure(description: description, filePath: filePath,
        lineNumber: lineNumber, expected: expected))
}

class LolSwift: NSObject {
    override class func initialize() {
        let recordFailure_IMP = imp_implementationWithBlock(unsafeBitCast(recordFailure_block,to: AnyObject.self))
        let recordFailure_method = class_getInstanceMethod(XCTestCase.self, #selector(XCTestCase.recordFailure))
        let _ = method_setImplementation(recordFailure_method, recordFailure_IMP)
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

    let testSuite = XCTestSuite.default()
    let suiteRun = XCTestSuiteRun(test: testSuite)
    testSuite.perform(suiteRun)
    var failureCount = 0

    for testRun in suiteRun.testRuns {
        let suites = (testRun.test as! XCTestSuite).tests

        for suite in suites {
            if let suiteName = suite.name {
                print(suiteName + "\n")
            }

            for test in (suite as! XCTestSuite).tests {
                let testCase = test as! XCTestCase

                let status = testCase.success ? "✅" : "❌"
                if let testCaseName = testCase.name {
                    print("\(status)  \(testCaseName)")
                }

                if (testCase.success) {
                    continue
                }

                failureCount += 1

                for failure in testCase.records {
                    print("\t\(failure)")
                }
            }
        }
    }

    let format = ".3"
    print("\n Executed \(suiteRun.executionCount) tests, with \(failureCount) failures (\(failureCount) unexpected) in \(suiteRun.testDuration.format(f: format)) seconds")

    return failureCount == 0
}
