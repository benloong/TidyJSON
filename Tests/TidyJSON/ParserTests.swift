import XCTest

#if !os(tvOS)
    import XCTest3
#else
    #if swift(>=3.0)
    #else
    extension XCTestCase {
        func measure(block: () -> Void) {
            self.measureBlock(block)
        }
    }
    #endif
#endif

import TidyJSON
import Foundation

class ParserTests: XCTestCase {
    
    func testParseNull() {
        let json = try? JSON.parse("null")
        XCTAssertTrue(json!.isNull)
        
        let json1 = try? JSON.parse("nu")
        XCTAssertTrue(json1 == nil)
        
        let json2 = try? JSON.parse("nil")
        XCTAssertTrue(json2 == nil)
    }
    
    func testParseString() {
        
        let json = try? JSON.parse("\"hello\"")
        let json1 = try? JSON.parse("\"\\u0041pple\"")
        let json2 = try? JSON.parse("\"\\\\ line1 \\n tab \\t \\r \\/\"")
        XCTAssertEqual(json!.string!, "hello")
        XCTAssertEqual(json1!.string!, "Apple")
        XCTAssertEqual(json2!.string!, "\\ line1 \n tab \t \r /")
        
        let json3 = try? JSON.parse("hello\"")
        XCTAssertTrue(json3 == nil)
        
        let json4 = try? JSON.parse("\"hello")
        XCTAssertTrue(json4 == nil)
    }
    
    func testParseTrue() {
        let json = try? JSON.parse("true")
        
        XCTAssertEqual(json!.bool!, true)
        
        let json1 = try? JSON.parse("tru")
        XCTAssertTrue(json1 == nil)
    }
    
    func testParseFalse() {
        let json = try? JSON.parse("false")
        
        XCTAssertEqual(json!.bool!, false)
        
        let json1 = try? JSON.parse("fa")
        XCTAssertTrue(json1 == nil)
    }
    
    func testParseNumber() {
        let json = try? JSON.parse("-120003e-1 ")
        XCTAssertEqual(json!.double!, -120003e-1)
        
        let json1 = try? JSON.parse("2.3E12 ")
        XCTAssertEqual(json1!.double!, 2.3E12)
        
        let json2 = try? JSON.parse("7.450580596923828e-9 ")
        XCTAssertEqual(json2!.double!, 7.450580596923828e-9)
    }
    
    func testParseArray() {
        let json = try? JSON.parse("[]")
        XCTAssertNotNil(json!.array)
        XCTAssertEqual(json!.count, 0)
        
        let json1 = try? JSON.parse("[1,2,3")
        XCTAssertTrue(json1 == nil)
        
        let json2 = try? JSON.parse("]")
        XCTAssertTrue(json2 == nil)
        
        let json3 = try? JSON.parse("[1,2,hello]")
        XCTAssertTrue(json3 == nil)
        
        let json4 = try? JSON.parse("[\"hello]\", 12, false, true, null]")
        XCTAssertEqual(json4!.count, 5)
        
        let json5 = try? JSON.parse("[,]")
        XCTAssertTrue(json5 == nil)
    }
    
    func testParseObject() {
        let json = try? JSON.parse("{}")
        XCTAssertNotNil(json!.object)
        XCTAssertEqual(json!.count, 0)
        
        let json1 = try? JSON.parse("{\"key\":12}")
        XCTAssertTrue(json1 != nil)
        
        let json2 = try? JSON.parse("{\"key\", 123")
        XCTAssertTrue(json2 == nil)
        
        let json3 = try? JSON.parse("{\"key\":\"hello\"}")
        XCTAssertTrue(json3!["key"].string! == "hello")
    }
    
    func testParseTestCases() {
        //XCTAssertTrue(testFailCase("fail1"))
        XCTAssertTrue(testFailCase("fail2"))
        XCTAssertTrue(testFailCase("fail3"))
        XCTAssertTrue(testFailCase("fail4"))
        XCTAssertTrue(testFailCase("fail5"))
        XCTAssertTrue(testFailCase("fail6"))
        //XCTAssertTrue(testFailCase("fail7"))
        //XCTAssertTrue(testFailCase("fail8"))
        XCTAssertTrue(testFailCase("fail9"))
        //XCTAssertTrue(testFailCase("fail10"))
        XCTAssertTrue(testFailCase("fail11"))
        XCTAssertTrue(testFailCase("fail12"))
        //XCTAssertTrue(testFailCase("fail13"))
        //XCTAssertTrue(testFailCase("fail14")) extend Numbers can be hex
        XCTAssertTrue(testFailCase("fail15"))
        XCTAssertTrue(testFailCase("fail16"))
        XCTAssertTrue(testFailCase("fail17"))
        //XCTAssertTrue(testFailCase("fail18"))
        XCTAssertTrue(testFailCase("fail19"))
        XCTAssertTrue(testFailCase("fail20"))
        XCTAssertTrue(testFailCase("fail21"))
        XCTAssertTrue(testFailCase("fail22"))
        XCTAssertTrue(testFailCase("fail23"))
        XCTAssertTrue(testFailCase("fail24"))
        //XCTAssertTrue(testFailCase("fail25"))
        XCTAssertTrue(testFailCase("fail26"))
        //XCTAssertTrue(testFailCase("fail27"))
        XCTAssertTrue(testFailCase("fail28"))
        XCTAssertTrue(testFailCase("fail29"))
        XCTAssertTrue(testFailCase("fail30"))
        XCTAssertTrue(testFailCase("fail31"))
        XCTAssertTrue(testFailCase("fail32"))
        XCTAssertTrue(testFailCase("fail33"))
        XCTAssertTrue(testPassCase("pass1"))
        XCTAssertTrue(testPassCase("pass2"))
        XCTAssertTrue(testPassCase("pass3"))
    }
    
    #if os(Linux)
    func testFailCase(path: String) -> Bool {
        do {
            let content = try String(contentsOfFile: "./Tests/TidyJSON/TestCases/\(path).json", encoding: NSUTF8StringEncoding)
            if let _ = try? JSON.parse(content) {
                return false
            } else {
                return true
            }
        }
        catch {
    
        }
        return false
    }
    
    func testPassCase(path: String) -> Bool {
        do {
            let content = try String(contentsOfFile: "./Tests/TidyJSON/TestCases/\(path).json", encoding: NSUTF8StringEncoding)
            if let _ = try? JSON.parse(content) {
                return true
            }
            else {
                return false
            }
        }
        catch {
    
        }
        return false
    }
    #else
    func testFailCase(path: String) -> Bool{
        do {
            if let file = NSBundle(for: ParserTests.self).path(forResource: path, ofType: "json") {
                let content = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                if let json = try? JSON.parse(content) {
                    print(json.dump())
                    return false
                }
                else {
                    return true
                }
            }
        }
        catch {
            
        }
        
        return false
    }
    
    func testPassCase(path: String) -> Bool {
        do {
            if let file = NSBundle(for: ParserTests.self).path(forResource: path, ofType: "json") {
                let content = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                
                if let _ = try? JSON.parse(content) {
                    return true
                }
                else {
                    return false
                }
            }
        }
        catch {
            
        }
        return false
    }
    
    func testParsePerformance() {
        do {
            if let file = NSBundle(for: ParserTests.self).path(forResource: "citm_catalog", ofType: "json") {
                let content = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                self.measure {
                    if let _ = try? JSON.parse(content) {
                        return
                    }
                    else {
                        return
                    }
                }
            }
        }
        catch {
            
        }
        return
    }
    #endif
}

#if os(Linux)
extension ParserTests {
	static var allTests : [(String, ParserTests -> () throws -> Void)] {
		return [
			("testParseNull", testParseNull),
			("testParseString", testParseString),
			("testParseTrue", testParseTrue),
			("testParseFalse", testParseFalse),
			("testParseNumber", testParseNumber),
			("testParseArray", testParseArray),
			("testParseObject", testParseObject),
			("testParseTestCases", testParseTestCases),
		]
	}
}
#endif