import XCTest
@testable import TidyJSONTestSuite

XCTMain([testCase(ValueTests.allTests), testCase(ParserTests.allTests), testCase(DumpTests.allTests), testCase(ModifyTests.allTests)])