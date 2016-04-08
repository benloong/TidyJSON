import XCTest

@testable import TidyJSONTestSuite

XCTMain([
	testCase(DumpTests.allTests),
	testCase(ModifyTests.allTests),
	testCase(ParserTests.allTests),
	testCase(ValueTests.allTests),
])