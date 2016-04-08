import XCTest

#if !os(tvOS)
    import XCTest3
#endif

import TidyJSON
import Foundation

class ValueTests: XCTestCase {
    
    func testNull() {
        let json : JSON = nil
        let json1 : JSON = [nil, nil]
        let json2 : JSON = ["key": nil]
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json1[0].isNull)
        XCTAssertTrue(json2["key"].isNull)
    }
    
    func testTrue() {
        let json : JSON = true
        let json1 : JSON = [true, true]
        let json2 : JSON = ["key" : true]
        XCTAssertTrue(json.bool!)
        XCTAssertTrue(json1[0].bool!)
        XCTAssertTrue(json1[1].bool!)
        
        XCTAssertTrue(json2["key"].bool!)
    }
    
    func testFalse() {
        let json : JSON = false
        let json1 : JSON = [false, false]
        let json2 : JSON = ["key" : false]
        XCTAssertFalse(json.bool!)
        XCTAssertFalse(json1[0].bool!)
        XCTAssertFalse(json1[1].bool!)
        
        XCTAssertFalse(json2["key"].bool!)
    }
    
    func testNumber() {
        let json : JSON = 1
        let json1 : JSON = 1.0
        let json2 : JSON = 1.23e2
        let json3 : JSON = 66662882838882382838823828832823.0
        let json4 : JSON = 3.0e-2
        XCTAssertEqual(json.double!, 1.0)
        XCTAssertEqual(json.float!, 1.0)
        XCTAssertEqual(json.int!, 1)
        XCTAssertEqual(json1.double!, 1.0)
        XCTAssertEqual(json1.int!, 1)
        XCTAssertEqual(json2.float!, 1.23e2)
        XCTAssertEqual(json2.double!, 1.23e2)
        XCTAssertEqual(json3.double!, 66662882838882382838823828832823.0)
        XCTAssertEqual(json4.double!, 3.0e-2)
    }
    
    func testString() {
        let json : JSON = ""
        let json1 : JSON = "hello"
        let json2 : JSON = "he\r \n llo"
        let json3 : JSON = "hello \t \"world\" "
        
        XCTAssertEqual(json.string!, "")
        XCTAssertEqual(json1.string!, "hello")
        XCTAssertEqual(json2.string!, "he\r \n llo")
        XCTAssertEqual(json3.string!, "hello \t \"world\" ")
    }
    
    func testSingleDimensionalArraysGetter() {
        let json : JSON = ["1","2", "a", "B", "D"]
        XCTAssertEqual(json[0].string!, "1")
        XCTAssertEqual(json[1].string!, "2")
        XCTAssertEqual(json[2].string!, "a")
        XCTAssertEqual(json[3].string!, "B")
        XCTAssertEqual(json[4].string!, "D")
    }
    
    func testTwoDimensionalArraysGetter() {
        let json : JSON = ["1",[1,2,2.0], true]
        XCTAssertEqual(json[0].string!, "1")
        XCTAssertEqual(json[1][0].int!, 1)
        XCTAssertEqual(json[1][1].int!, 2)
        XCTAssertEqual(json[1][2].float!, 2.0)
        XCTAssertEqual(json[2].bool!, true)
    }
    
    func testObjectGetter() {
        let json : JSON = ["key":false, "key2":true, "key3":[1, "hello", 3, "world", ["key4":nil, "key5":12.03, "key6":12E-2, "key7": -12e-2]]]
        XCTAssertEqual(json["key"].bool!, false)
        XCTAssertEqual(json["key2"].bool!, true)
        XCTAssertNotNil(json["key3"].array)
        XCTAssertNotNil(json["key3"][4].object)
        XCTAssertEqual(json["key3"][4]["key4"].isNull, true)
        XCTAssertEqual(json["key3"][4]["key5"].float!, 12.03)
    }
}

#if os(Linux)
extension ValueTests {
	static var allTests : [(String, ValueTests -> () throws -> Void)] {
		return [
			("testNull", testNull),
			("testTrue", testTrue),
			("testFalse", testFalse),
			("testNumber", testNumber),
			("testString", testString),
			("testSingleDimensionalArraysGetter", testSingleDimensionalArraysGetter),
			("testTwoDimensionalArraysGetter", testTwoDimensionalArraysGetter),
			("testObjectGetter", testObjectGetter),
		]
	}
}
#endif