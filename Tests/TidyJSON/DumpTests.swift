import XCTest

#if !os(tvOS)
    import XCTest3
#endif

import TidyJSON
import Foundation

class DumpTests: XCTestCase {
    
    func testDumpDataValue() {
        let json : JSON = nil
        XCTAssertEqual (json.dump(), "null")
        
        let json1 : JSON = "1.02"
        XCTAssertEqual(json1.dump(), "\"1.02\"")
        
        let json2 : JSON = true
        XCTAssertEqual(json2.dump(), "true")
        
        let json3 : JSON = false
        XCTAssertEqual(json3.dump(), "false")
        
        let json4: JSON = 1.23
        XCTAssertEqual(json4.dump(), "1.23")
        
        let json5: JSON = "hello\n world. \r \\ yes /hello"
        XCTAssertEqual(json5.dump(), "\"hello\\n world. \\r \\\\ yes \\/hello\"")
    }
    
    func testDumpArray() {
        let json: JSON = ["v",0.3, true, false, nil, [], ["key": false]]
        XCTAssertEqual(json.dump(), "[\"v\",0.3,true,false,null,[],{\"key\":false}]")
        
        let s = "[\"hello]\",12,false,true,null]"
        let json1 = try! JSON.parse(s)
        XCTAssertEqual(json1.dump(), s)
    }
    
    func testDumpObject() {
        let json: JSON = ["key2":[false,true,2,[],"hello"]]
        XCTAssertEqual(json.dump(), "{\"key2\":[false,true,2,[],\"hello\"]}")
        
        let json1 = try! JSON.parse("{\"key\":\"hello\"}")
        XCTAssertEqual(json1.dump(), "{\"key\":\"hello\"}")
    }
}

#if os(Linux)
extension DumpTests {
	static var allTests : [(String, DumpTests -> () throws -> Void)] {
		return [
			("testDumpDataValue", testDumpDataValue),
			("testDumpArray", testDumpArray),
			("testDumpObject", testDumpObject),
		]
	}
}
#endif