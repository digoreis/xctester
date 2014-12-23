import ObjectiveC
import XCTest

var AssociatedObjectHandle: UInt8 = 0

class Failure : NSObject, Printable {
    let failureDescription: String!
    let filePath: String!
    let lineNumber: Int
    let expected: Bool

     func description() -> String {
        return self.failureDescription
    }

    init(description: String!, filePath: String!, lineNumber: Int, expected: Bool) {
        failureDescription = description
        self.filePath = filePath
        self.lineNumber = lineNumber
        self.expected = expected
    }
}

extension NSTimeInterval {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

extension XCTestCase {
    var records: [Failure]! {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as [Failure]!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue,
                objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }

    var success: Bool {
        return self.records == nil || self.records.count == 0
    }

    func recordFailureWithDescription(description: String!, inFile filePath: String!,
        atLine lineNumber: Int, expected: Bool) {
            if self.records == nil {
                self.records = [Failure]()
            }

            self.records.append(Failure(description: description, filePath: filePath,
                lineNumber: lineNumber, expected: expected))
    }
}

func XCTestRunAll() {
    let suite = XCTestSuite.defaultTestSuite() as XCTestSuite!
    let suiteRun = suite.run() as XCTestSuiteRun
    var failureCount = 0

    for testRun in suiteRun.testRuns {
        let suites = ((testRun as XCTestRun).test as XCTestSuite).tests

        for suite in suites {
            let testCaseName = suite.name
            println(testCaseName + "\n")

            for test in (suite as XCTestSuite).tests {
                let testCase = test as XCTestCase

                print(testCase.success ? "✅" : "❌")
                println("  \(testCase.name)")

                if (testCase.success) {
                    continue
                }

                failureCount++

                for failure in testCase.records {
                    print("\t")
                    println(failure)
                }
            }
        }
    }

    let format = ".3"
    println("\n Executed \(suiteRun.executionCount) tests, with \(failureCount) failures (\(failureCount) unexpected) in \(suiteRun.testDuration.format(format)) seconds")
}
