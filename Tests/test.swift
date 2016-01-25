import XCTest
import TidyJSON

class ValueTests: XCTestCase {

    var allTests : [(String, () throws -> ())] {
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

    var allTests : [(String, () throws -> ())] {
        return [
            ("testParseNull", testParseNull),
            ("testParseString", testParseString),
            ("testParseTrue", testParseTrue),
            ("testParseFalse", testParseFalse),
            ("testParseNumber", testParseNumber),
            ("testParseArray", testParseArray),
            ("testParseObject", testParseObject)
        ]
    }
    
    func testParseNull() {
        let (json, error) = JSON.parse("null")
        XCTAssertTrue(json!.isNull)
        XCTAssertTrue(error == nil)
        let (json1, error1) = JSON.parse("nu")
        XCTAssertTrue(json1 == nil)
        XCTAssertNotNil(error1)
        let (json2, error2) = JSON.parse("nil")
        XCTAssertTrue(json2 == nil)
        XCTAssertNotNil(error2)
    }
    
    func testParseString() {
        let (json, _) = JSON.parse("\"hello\"")
        let (json1, _) = JSON.parse("\"\\u0041pple\"")
        let (json2, _) = JSON.parse("\"\\\\ line1 \\n tab \\t \\r \\/\"")
        XCTAssertEqual(json!.string!, "hello")
        XCTAssertEqual(json1!.string!, "Apple")
        XCTAssertEqual(json2!.string!, "\\ line1 \n tab \t \r /")
        
        let (json3, error3) = JSON.parse("hello\"")
        XCTAssertTrue(json3 == nil)
        XCTAssertNotNil(error3)
        
        let (json4, error4) = JSON.parse("\"hello")
        XCTAssertTrue(json4 == nil)
        XCTAssertNotNil(error4)
    }
    
    func testParseTrue() {
        let (json, _) = JSON.parse("true")
        
        XCTAssertEqual(json!.bool!, true)
        
        let (json1, error1) = JSON.parse("tru")
        XCTAssertTrue(json1 == nil)
        XCTAssertNotNil(error1)
    }
    
    func testParseFalse() {
        let (json, _) = JSON.parse("false")
        
        XCTAssertEqual(json!.bool!, false)
        
        let (json1, error1) = JSON.parse("fa")
        XCTAssertTrue(json1 == nil)
        XCTAssertNotNil(error1)
    }
    
    func testParseNumber() {
        let (json, _) = JSON.parse("-120003e-1")
        XCTAssertEqual(json!.double!, -120003e-1)
        
        let (json1, _) = JSON.parse("2.3E12")
        XCTAssertEqual(json1!.double!, 2.3E12)
        
        let (json2, _) = JSON.parse("7.450580596923828e-9")
        XCTAssertEqual(json2!.double!, 7.450580596923828e-9)
    }
    
    func testParseArray() {
        let (json, _) = JSON.parse("[]")
        XCTAssertNotNil(json!.array)
        XCTAssertEqual(json!.count, 0)
        let (json1, _) = JSON.parse("[1,2,3")
        XCTAssertTrue(json1 == nil)
        
        let (json2, _) = JSON.parse("]")
        XCTAssertTrue(json2 == nil)
        
        let (json3, _) = JSON.parse("[1,2,hello]")
        XCTAssertTrue(json3 == nil)
        
        let (json4, _) = JSON.parse("[\"hello]\", 12, false, true, null]")
        XCTAssertEqual(json4!.count, 5)
        
        let (json5,_) = JSON.parse("[,]")
        XCTAssertTrue(json5 == nil)
    }
    
    func testParseObject() {
        let (json, _) = JSON.parse("{}")
        XCTAssertNotNil(json!.object)
        XCTAssertEqual(json!.count, 0)
        let (json1, _) = JSON.parse("{\"key\":12}")
        XCTAssertTrue(json1 != nil)
        
        let (json2, _) = JSON.parse("{\"key\", 123")
        XCTAssertTrue(json2 == nil)
        
        let (json3, _) = JSON.parse("{\"key\":\"hello\"}")
        XCTAssertTrue(json3!["key"].string! == "hello")
    }
}

class DumpTests: XCTestCase {
    var allTests : [(String, () throws -> ())] {
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
        
        let s = "[\"hello]\",12.0,false,true,null]"
        let (json1, _) = JSON.parse(s)
        XCTAssertEqual(json1!.dump(), s)
    }
    
    func testDumpObject() {
        let json: JSON = ["key2":[false,true,2.0,[],"hello"]]
        XCTAssertEqual(json.dump(), "{\"key2\":[false,true,2.0,[],\"hello\"]}")
        
        let (json1, _) = JSON.parse("{\"key\":\"hello\"}")
        XCTAssertEqual(json1!.dump(), "{\"key\":\"hello\"}")
    }
}

class ModifyTests : XCTestCase {
    var allTests : [(String, () throws -> ())] {
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
XCTMain([ValueTests(), ParserTests(), DumpTests(), ModifyTests()])