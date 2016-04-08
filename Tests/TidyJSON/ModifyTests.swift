import XCTest

#if !os(tvOS)
    import XCTest3
#endif

import TidyJSON
import Foundation

class ModifyTests : XCTestCase {
    
    func testModifyArray() {
        var json : JSON = []
        let child :JSON = "string"
        json.append(child)
        XCTAssertEqual(json[0].string!, "string")
        
        json[0] = "STRING"
        XCTAssertEqual(json[0].string!, "STRING")
        
        json.append(JSON([]))
        json[1].append(JSON("hello"))
        XCTAssertEqual(json[1][0].string!, "hello")
        
        json[1][0] = "world"
        XCTAssertEqual(json[1][0].string!, "world")
        
        json[1].removeAtIndex(0)
        XCTAssertEqual(json[1].count, 0)
        XCTAssertEqual(json[0].string!, "STRING")
        
        json.removeAtIndex(1)
        XCTAssertEqual(json.count, 1)
    }
    
    func testModifyObject() {
        var json : JSON = [:]
        json["hello"] = false
        XCTAssertEqual(json.count, 1)
        
        json["world"] = true
        XCTAssertEqual(json.count, 2)
        XCTAssertEqual(json["hello"].bool!, false)
        XCTAssertEqual(json["world"].bool!, true)
        
        json["world"] = nil
        
        XCTAssertEqual(json.count, 1)
        XCTAssertEqual(json["world"].isNull, true)
        
        json["hello"] = [2,3,4,4]
        XCTAssertEqual(json["hello"].count, 4)
    }
}

#if os(Linux)
extension ModifyTests {
	static var allTests : [(String, ModifyTests -> () throws -> Void)] {
		return [
			("testModifyArray", testModifyArray),
			("testModifyObject", testModifyObject),
		]
	}
}
#endif