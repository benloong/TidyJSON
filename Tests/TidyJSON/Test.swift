import XCTest
import TidyJSON
import Foundation

class ValueTests: XCTestCase {

    static var allTests : [(String, ValueTests -> () throws -> ())] {
        return [
            ("testNull", testNull),
            ("testTrue", testTrue),
            ("testFalse", testFalse),
            ("testNumber", testNumber),
            ("testString", testString),
            ("1DArrayGetter", testSingleDimensionalArraysGetter),
            ("2DArrayGetter", testTwoDimensionalArraysGetter),
            ("testObjectGetter", testObjectGetter)
        ]
    }
    
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


class ParserTests: XCTestCase {

    static var allTests : [(String, ParserTests -> () throws -> ())] {
        return [
            ("testParseNull", testParseNull),
            ("testParseString", testParseString),
            ("testParseTrue", testParseTrue),
            ("testParseFalse", testParseFalse),
            ("testParseNumber", testParseNumber),
            ("testParseArray", testParseArray),
            ("testParseObject", testParseObject),
            ("testParseTestCases", testParseTestCases)
        ]
    }
    
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

    func testFailCase(path: String) -> Bool {
        if let content = utf8(contentsOfFile: path) {
            if let _ = try? JSON.parse(content) {
                return false
            }
            return true
        }
        return false
    }
    
    func testPassCase(path: String) -> Bool {
        if let content = utf8(contentsOfFile: path) {
            if let _ = try? JSON.parse(content) {
                return true
            }
            return false
        }
        return false
    }
#if SWIFT_PACKAGE
    func utf8(contentsOfFile path: String) -> String? {
        return try? String(contentsOfFile: "./Tests/TestCases/\(path).json", encoding: NSUTF8StringEncoding)
    }
#else
    func utf8(contentsOfFile path: String) -> String? {
        if let file = NSBundle(for: ParserTests.self).path(forResource: path, ofType: "json") {
            return try? String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
#endif
}

class DumpTests: XCTestCase {
    static var allTests : [(String, DumpTests -> () throws -> ())] {
        return [
            ("testDumpDataValue", testDumpDataValue),
            ("testDumpArray", testDumpArray),
            ("testDumpObject", testDumpObject)
        ]
    }
    
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

class ModifyTests : XCTestCase {
    static var allTests : [(String, ModifyTests -> () throws -> ())] {
        return [
            ("testModifyArray", testModifyArray),
            ("testModifyObject", testModifyObject)
        ]
    }
    
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
        
        json[1].remove(at: 0) 
        XCTAssertEqual(json[1].count, 0)
        XCTAssertEqual(json[0].string!, "STRING")
        
        json.remove(at: 1)
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