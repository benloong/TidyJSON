import XCTest
@testable import TidyJSONTests

XCTMain([testCase(ValueTests.allTests), testCase(ParserTests.allTests), testCase(DumpTests.allTests), testCase(ModifyTests.allTests)])