#if os(OSX) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

import Foundation

public enum JSON {
    /**
     * Box wrapper for array value
     */
    public class _ArrayBox {
        var array : [JSON]
        init(_ a: [JSON]) {
            array = a
        }
    }
    
    /**
     * Box wrapper for object value
     */
    public class _DictBox {
        var dict: [Swift.String : JSON]
        init(_ d: [Swift.String : JSON]) {
            dict = d
        }
    }
    
    /**
     * JSON null value
     */
    case Null
    
    /**
     * JSON bool value(true, false)
     */
    case Boolean(_: Bool)
    
    /**
     * JSON number value
     */
    case Number(_: Double)
    
    /**
     * JSON string value
     */
    case String(_: Swift.String)
    
    /**
     * JSON array value
     */
    case Array(_: _ArrayBox)
    
    /**
     * JSON object value
     */
    case Object(_: _DictBox)
}

//MARK: - Literal convert
extension JSON : NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .Null
    }
    
    /**
     * Check if this JSON is Null value
     */
    public var isNull : Bool {
        switch self {
        case .Null: return true
        default: return false
        }
    }
}

extension JSON : BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Boolean(value)
    }
    
    public init(_ b: Bool) {
        self = .Boolean(b)
    }
    
    /**
     * Boolean value of this JSON, only for bool value
     */
    public var bool : Bool? {
        switch self {
        case .Boolean(let x): return x
        default: return nil
        }
    }
}

extension JSON : FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Number(Double(value))
    }
    
    public init(_ value: Double) {
        self = .Number(value)
    }
    
    public init(_ value: Float) {
        self = .Number(Double(value))
    }
    
    /**
     * Double floating value of this JSON, only for number value
     */
    public var double : Double? {
        switch self {
        case .Number(let x): return x
        default: return nil
        }
    }
    
    /**
     * Single floating value of this JSON, only for number value
     */
    public var float : Float? {
        switch self {
        case .Number(let x): return Float(x)
        default: return nil
        }
    }
}

extension JSON : IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Number(Double(value))
    }
    
    public init(_ value: Int) {
        self = .Number(Double(value))
    }
    
    /**
     * Integer value of this JSON, only for number value
     */
    public var int : Int? {
        switch self {
        case .Number(let x) where x % 1 == 0: return Int(x)
        default: return nil
        }
    }
}

extension JSON : StringLiteralConvertible {
    public init(stringLiteral value: StringLiteralType) {
        self = .String(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .String(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .String(value)
    }
    
    public init(_ string: Swift.String) {
        self = .String(string)
    }
    
    /**
     * string value of this JSON, only null, string, true, false, number values not nil
     */
    public var string : Swift.String? {
        switch self {
        case .String(let x): return x
        case .Null: return "null"
        case .Boolean(let b): return b.description
        case .Number(let n): return n.description
        default: return nil
        }
    }
}

extension JSON : ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSON...) {
        var array = [JSON]()
        for e in elements {
            array.append(e)
        }
        self = .Array(_ArrayBox(array))
    }
    
    public init(_ array: [JSON]) {
        self = .Array(_ArrayBox(array))
    }
    
    /**
     * Internal Array container of this JSON
     */
    public var array : [JSON]? {
        switch self {
        case .Array(let x): return x.array
        default: return nil
        }
    }
    
    /**
     * Append newElement to the Array JSON.
     */
    public func append(newElement: JSON) {
        switch self {
        case .Array(let x): x.array.append(newElement)
        default: break
        }
    }
    
    /**
     * Remove and return the child json at index i.
     */
    public func removeAtIndex(index: Int) -> JSON? {
        switch self {
        case .Array(let x): return x.array.removeAtIndex(index)
        default: return nil
        }
    }
}

extension JSON : DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (Swift.String, JSON)...) {
        var dict : [Swift.String : JSON] = [:]
        for (k, v) in elements {
            dict[k] = v
        }
        
        self = .Object(_DictBox(dict))
    }
    
    public init(_ dict: [Swift.String : JSON]) {
        self = .Object(_DictBox(dict))
    }
    
    /**
     * Internal Dictionary container of this JSON
     */
    public var object : [Swift.String : JSON]? {
        switch self {
        case .Object(let x): return x.dict
        default: return nil
        }
    }
}

//MARK: - sequenceType

/**
* for-in Loop support
*/
extension JSON : SequenceType {
    /**
     * The number of children in this JSON
     */
    public var count : Int {
        switch self {
        case .Object(let obj): return obj.dict.count
        case .Array(let arr): return arr.array.count
        default: return 0
        }
    }
    
    public func generate() -> JSON.Generator {
        return JSON.Generator(json: self)
    }
    
    //MARK: - generator
    public struct Generator : GeneratorType {
        
        public typealias Element = (Swift.String, JSON)
        
        var arrayGenerator: IndexingGenerator<[JSON]>?
        var objectGenerator: DictionaryGenerator<Swift.String, JSON>?
        var index : Int = 0
        init(json: JSON) {
            switch json {
            case .Object(let obj): objectGenerator = obj.dict.generate()
            case .Array(let arr): arrayGenerator = arr.array.generate()
            default: break
            }
        }
        
        public mutating func next() -> Generator.Element? {
            if let arrayElement =  arrayGenerator?.next() {
                let _index = index
                index += 1
                return (Swift.String(_index), arrayElement)
            }
            if let objectElement = objectGenerator?.next() {
                return objectElement
            }
            return nil
        }
    }
}

//MARK: - subscript
extension JSON {
    public subscript(i : Int) -> JSON {
        get {
            switch self {
            case .Array(let a): return a.array[i]
            default: return nil
            }
        }
        
        set {
            switch self {
            case .Array(let a): a.array[i] = newValue
            default: break
            }
        }
    }
    
    public subscript(key : Swift.String) -> JSON {
        get {
            switch self {
            case .Object(let o): return o.dict[key] ?? nil
            default: return nil
            }
        }
        set {
            switch self {
            case .Object(let o):
                if newValue.isNull {
                    o.dict[key] = nil
                }
                else {
                    o.dict[key] = newValue
                }
            default: break
            }
        }
    }
}

//MARK: - Parser
extension JSON {
    /**
     * parse JSON from string, return nil or valid JSON
     */
    public static func parse(string: Swift.String) throws -> JSON {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            return try parse(data)
        }
        return nil
    }
    
    /**
     * parse JSON from data buffer, return nil or valid JSON
     */
    public static func parse(data: NSData) throws -> JSON {
        let buffer = UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
        var parser = Parser(buffer)
        return try parser.parse().0
    }
}

//MARK: - String representation internal

extension JSON {
    public func dump() -> Swift.String {
        var result = ""
        dump(&result)
        return result
    }
    
    func dump(inout string: Swift.String) {
        switch self {
        case .Null : string.appendContentsOf("null")
        case .Boolean(let b) : dumpBool(&string, bool: b)
        case .Number(let n) : dumpNumber(&string, number: n)
        case .String(let s) : dumpString(&string, jsonString: s)
        case .Array(let a) : dumpArray(&string, array: a.array)
        case .Object(let o) : dumpObject(&string, object: o.dict)
        }
    }
    
    func dumpBool(inout string: Swift.String, bool: Bool) {
        if bool {
            string.appendContentsOf("true")
        }
        else {
            string.appendContentsOf("false")
        }
    }
    
    func dumpNumber(inout string: Swift.String, number: Double) {
        if number % 1 == 0 {
            string.appendContentsOf(Swift.String(Int(number)))
        }
        else {
            string.appendContentsOf(Swift.String(number))
        }
    }
    
    func dumpArray(inout string: Swift.String, array: [JSON]) {
        let comma : UnicodeScalar = ","
        let open : UnicodeScalar = "["
        let close : UnicodeScalar = "]"
        string.append(open)
        for child in array {
            child.dump(&string)
            string.append(comma)
        }
        // remove last comma
        if array.count > 0 {
            string.removeAtIndex(string.endIndex.advancedBy(-1))
        }
        string.append(close)
        return
    }
    
    func dumpObject(inout string: Swift.String, object: [Swift.String : JSON]) {
        let comma : UnicodeScalar = ","
        let open : UnicodeScalar = "{"
        let close : UnicodeScalar = "}"
        let colon : UnicodeScalar = ":"
        string.append(open)
        for (k, v) in object {
            dumpString(&string, jsonString: k)
            string.append(colon)
            v.dump(&string)
            string.append(comma)
        }
        // remove last comma
        if object.count > 0 {
            string.removeAtIndex(string.endIndex.advancedBy(-1))
        }
        string.append(close)
    }
    
    func dumpString(inout string: Swift.String, jsonString: Swift.String) {
        let rs : UnicodeScalar = "\\"
        let s : UnicodeScalar = "/"
        let q : UnicodeScalar = "\""
        let b : UnicodeScalar = "b"
        let f : UnicodeScalar = "f"
        let n : UnicodeScalar = "n"
        let r : UnicodeScalar = "r"
        let t : UnicodeScalar = "t"
        
        string.append(q)
        for ch in jsonString.characters {
            switch ch {
            case "\\" : string.append(rs); string.append(rs)
            case "/" : string.append(rs); string.append(s)
            case "\"" : string.append(rs); string.append(q)
            case "\n" : string.append(rs); string.append(n)
            case "\r" : string.append(rs); string.append(r)
            case "\t" : string.append(rs); string.append(t)
            case "\u{8}" : string.append(rs); string.append(b)
            case "\u{c}" : string.append(rs); string.append(f)
            default: string.append(ch)
            }
        }
        string.append(q)
    }
}

public struct ParseError : ErrorType {
    let error: String
    init(_ error: String) {
        self.error = error
    }
}

//MARK: - Parser internal
struct Parser {
    private enum Token {
        case None
        case CurlyOpen
        case CurlyClose
        case SquareOpen
        case SquareClose
        case Colon
        case Comma
        case Number
        case String
        case True
        case False
        case Null
    }
    
    /// Whitespace (space \n \r \t)
    static let whitespaceTable : [UInt8] =
    [
        // 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
        0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  0,  0,  1,  0,  0,  // 0
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 1
        1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 2
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 3
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 4
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 5
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 6
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 7
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 8
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // 9
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // A
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // B
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // C
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // D
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  // E
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0   // F
    ]
    
    ///// Digits (dec and hex, 255 denotes end of numeric character reference)
    static let digitTable : [UInt8] =
    [
        // 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 0
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 1
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 2
        0,  1,  2,  3,  4,  5,  6,  7,  8,  9,255,255,255,255,255,255,  // 3
        255, 10, 11, 12, 13, 14, 15,255,255,255,255,255,255,255,255,255,  // 4
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 5
        255, 10, 11, 12, 13, 14, 15,255,255,255,255,255,255,255,255,255,  // 6
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 7
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 8
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // 9
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // A
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // B
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // C
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // D
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,  // E
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255   // F
    ]
    
    static let a = UInt8(ascii: "a")
    static let b = UInt8(ascii: "b")
    static let e = UInt8(ascii: "e")
    static let E = UInt8(ascii: "E")
    static let f = UInt8(ascii: "f")
    static let l = UInt8(ascii: "l")
    static let n = UInt8(ascii: "n")
    static let r = UInt8(ascii: "r")
    static let s = UInt8(ascii: "s")
    static let t = UInt8(ascii: "t")
    static let u = UInt8(ascii: "u")
    
    static let _0 = UInt8(ascii:"0")
    static let _1 = UInt8(ascii:"1")
    static let _2 = UInt8(ascii:"2")
    static let _3 = UInt8(ascii:"3")
    static let _4 = UInt8(ascii:"4")
    static let _5 = UInt8(ascii:"5")
    static let _6 = UInt8(ascii:"6")
    static let _7 = UInt8(ascii:"7")
    static let _8 = UInt8(ascii:"8")
    static let _9 = UInt8(ascii:"9")
    
    static let backslash = UInt8(ascii:"\\")
    static let slash = UInt8(ascii:"/")
    static let quote = UInt8(ascii:"\"")
    static let backspace = UInt8(ascii:"\u{8}")
    static let formfeed = UInt8(ascii:"\u{c}")
    static let newline = UInt8(ascii:"\n")
    static let `return` = UInt8(ascii:"\r")
    static let tab = UInt8(ascii:"\t")
    static let space = UInt8(ascii:" ")
    static let leftbrace = UInt8(ascii:"{")
    static let rightbrace = UInt8(ascii:"}")
    static let leftbracket = UInt8(ascii:"[")
    static let rightbracket = UInt8(ascii:"]")
    static let comma = UInt8(ascii:",")
    static let colon = UInt8(ascii:":")
    static let minus = UInt8(ascii:"-")
    static let plus = UInt8(ascii:"+")
    static let dot = UInt8(ascii:".")
    
    /// reusable temp buffer for string decoding
    private var tempStringBuffer = [UInt8]()
    
    /// utf8 encoding string bytes
    let string : UnsafeBufferPointer<UInt8>
    
    init(_ buffer: UnsafeBufferPointer<UInt8>) {
        self.string = buffer
    }
    
    mutating func parse() throws -> (JSON, Int) {
        return try self.parseValue(0)
    }
    
    private mutating func _parseString(index: Int) throws -> (String?, Int) {
        // skip first '\"' character
        var cursor = index.successor()
        
        tempStringBuffer.removeAll(keepCapacity: true)
        
        while cursor != string.endIndex {
            switch string[cursor] {
            case Parser.backslash:
                cursor = cursor.successor()
                // invalid json format
                if  cursor == string.endIndex {
                    throw ParseError("invalid json: not expect end at \(cursor)")
                }
                let ch = string[cursor]
                switch ch {
                case Parser.backslash: tempStringBuffer.append(Parser.backslash)
                case Parser.slash: tempStringBuffer.append(Parser.slash)
                case Parser.quote: tempStringBuffer.append(Parser.quote)
                case Parser.b: tempStringBuffer.append(Parser.backspace)
                case Parser.f: tempStringBuffer.append(Parser.formfeed)
                case Parser.n: tempStringBuffer.append(Parser.newline)
                case Parser.r: tempStringBuffer.append(Parser.`return`)
                case Parser.t: tempStringBuffer.append(Parser.tab)
                case Parser.u:
                    // parse unicode scalar hex digit
                    var hex = 0
                    // skip 'u'
                    cursor = cursor.successor()
                    guard cursor.distanceTo(string.endIndex) > 3 else {
                        throw ParseError("invalid json: unexpected unicode hex digit at \(cursor) ")
                    }
                    
                    let digit0 = Int(Parser.digitTable[Int(string[cursor])])
                    let digit1 = Int(Parser.digitTable[Int(string[cursor+1])])
                    let digit2 = Int(Parser.digitTable[Int(string[cursor+2])])
                    let digit3 = Int(Parser.digitTable[Int(string[cursor+3])])
                    
                    guard digit0 != 255 && digit1 != 255 && digit2 != 255 && digit3 != 255 else {
                        throw ParseError("invalid json: unexpected unicode hex digit at \(cursor) ")
                    }
                    
                    hex = hex | (digit0 << 12)
                    hex = hex | (digit1 << 8)
                    hex = hex | (digit2 << 4)
                    hex = hex | (digit3)
                    
                    let unicode = UnicodeScalar(hex)
                    UTF8.encode(unicode, output: { self.tempStringBuffer.append($0) })
                    
                    cursor = cursor.advancedBy(3)
                    // invalid json format
                default: throw ParseError("invalid json: illegal character \(ch) after '\\' at \(cursor)")
                }
                
            case Parser.quote:
                tempStringBuffer.append(0)
                return (tempStringBuffer.withUnsafeBufferPointer(decodeString), cursor.successor())
            default: tempStringBuffer.append(string[cursor])
            }
            cursor = cursor.successor()
        }
        throw ParseError("invalid json: expect character \" at \(cursor)")
    }
    
    private func decodeString(buffer: UnsafeBufferPointer<UInt8>) -> String? {
        return String.fromCString(UnsafePointer(buffer.baseAddress))
    }
    
    /**
     * skip all whitespace
     */
    private func eatWhiteSpace(index: Int) -> Int {
        var cursor = index
        while (cursor != string.endIndex) {
            let ch = Parser.whitespaceTable[Int(string[cursor])]
            if ch == 0 {
                return cursor
            }
            else {
                cursor = cursor.successor()
            }
        }
        return cursor
    }
    
    /**
     * get next token and index of this token
     */
    private func nextToken(index: Int) -> (Token, Int) {
        var cursor = eatWhiteSpace(index)
        var token : Token = .None
        
        if cursor != string.endIndex {
            let char = string[cursor]
            switch char {
            case Parser.leftbrace: token = .CurlyOpen
            case Parser.rightbrace: token = .CurlyClose
            case Parser.leftbracket: token = .SquareOpen
            case Parser.rightbracket: token = .SquareClose
            case Parser.comma: token = .Comma
            case Parser.colon: token = .Colon
            case Parser.quote: token = .String
            case Parser.f: token = .False
            case Parser.t: token = .True
            case Parser.n: token = .Null
            case Parser.minus, Parser._0, Parser._1, Parser._2, Parser._3, Parser._4, Parser._5, Parser._6, Parser._7, Parser._8, Parser._9: token = .Number
            default: break
            }
        }
        
        cursor = eatWhiteSpace(cursor)
        return (token, cursor)
    }
    
    private mutating func parseValue(index: Int) throws -> (JSON, Int) {
        let (token, cursor) = nextToken(index)
        
        switch token {
        case .CurlyOpen : return try parseObject(cursor)
        case .SquareOpen : return try parseArray(cursor)
        case .Number : return try parseNumber(cursor)
        case .String : return try parseString(cursor)
        case .False: return try parseFalse(cursor)
        case .True: return try parseTrue(cursor)
        case .Null: return try parseNull(cursor)
        default: break
        }
        throw ParseError("invalid json: character invalid at \(cursor)")
    }
    
    private mutating func parseString(index: Int) throws -> (JSON, Int) {
        let (s, cursor) = try _parseString(index)
        if let json = s {
            return (JSON(json), cursor)
        }
        throw ParseError("invalid json: expect string at \(index)")
    }
    
    func parseDouble(address: UnsafePointer<UInt8>) -> (Double, Int.Distance)? {
        let startPointer = UnsafePointer<Int8>(address)
        let endPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.alloc(1)
        defer { endPointer.dealloc(1) }
        
        let result = strtod(startPointer, endPointer)
        let distance = startPointer.distanceTo(endPointer[0])
        guard distance > 0 else {
            return nil
        }
        
        return (result, distance)
    }
    
    private mutating func parseNumber(index: Int) throws -> (JSON, Int) {
        let cursor = index
        
        if let (double, distance) = parseDouble(string.baseAddress.advancedBy(cursor)) {
            return (JSON(double), cursor + distance)
        }
        throw ParseError("invalid json: expect number at\(cursor).")
    }
    
    private func parseNull(index: Int) throws -> (JSON, Int) {
        var cursor = index
        
        guard cursor != string.endIndex && string[cursor] == Parser.n else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.u else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.l else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.l else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        
        return (nil, cursor.successor())
    }
    
    private func parseTrue(index: Int) throws -> (JSON, Int) {
        var cursor = index
        
        guard cursor != string.endIndex && string[cursor] == Parser.t else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.r else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.u else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.e else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        
        return (true, cursor.successor())
    }
    
    private func parseFalse(index: Int) throws -> (JSON, Int) {
        var cursor = index
        
        guard cursor != string.endIndex && string[cursor] == Parser.f else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.a else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.l else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.s else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == Parser.e else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        return (false, cursor.successor())
    }
    
    private mutating func parseArray(index: Int) throws -> (JSON, Int) {
        var cursor = index
        
        guard string[cursor] == Parser.leftbracket else {
            // invalid json "[" start array
            throw ParseError("invalid json: expect '[' at \(cursor)")
        }
        
        // skip "["
        cursor = cursor.successor()
        cursor = eatWhiteSpace(cursor)
        
        var array = [JSON]()
        
        guard string[cursor] != Parser.rightbracket else {
            // empty array "[]" early return
            return (JSON(array), cursor.successor())
        }
        
        while cursor != string.endIndex {
            // parse value
            let (json, next) = try parseValue(cursor)
            
            cursor = next
            array.append(json)
            
            // next token  "," or "]"
            
            let (token, nextNext) = nextToken(cursor)
            switch token {
                // "," parse next value
            case .Comma: cursor = nextNext.successor()
                // "]" end array
            case .SquareClose: return (JSON(array), nextNext.successor())
                // invalid json
            default: throw ParseError("invalid json: expect ']' or ',' at \(nextNext)")
            }
        }
        
        // invalid json
        throw ParseError("invalid json: expect ']' or ',' at \(cursor)")
    }
    
    private mutating func parseObject(index: Int) throws -> (JSON, Int) {
        var cursor = index
        
        guard string[cursor] == Parser.leftbrace else {
            // invalid json "{" start array
            throw ParseError("invalid json: expect '{' at \(cursor). ")
        }
        
        // skip "{"
        cursor = cursor.successor()
        cursor = eatWhiteSpace(cursor)
        
        var object : [String : JSON] = [:]
        
        guard string[cursor] != Parser.rightbrace else {
            // empty object "{}" early return
            return (JSON(object), cursor.successor())
        }
        
        while cursor != string.endIndex {
            let (_key, afterKey) = try _parseString(eatWhiteSpace(cursor))
            guard let key = _key else {
                // parse key error, invalid json
                throw ParseError("invalid json: expect string at \(cursor)")
            }
            cursor = afterKey
            let (token1, tokenIndex) = nextToken(cursor)
            switch token1 {
            case .Colon: break
                
                // not match expect ":", invalid json
            default: throw ParseError("invalid json: expect ':' at \(tokenIndex)")
            }
            cursor = tokenIndex.successor()
            // parse value
            let (json, next) = try parseValue(cursor)
            
            cursor = next
            object[key] = json
            
            // next token  "," or "}"
            let (token, nextNext) = nextToken(cursor)
            switch token {
                // "," parse next value
            case .Comma: cursor = nextNext.successor()
                // "}" end object
            case .CurlyClose: return (JSON(object), nextNext.successor())
                // not expected token, invalid json
            default: throw ParseError("invalid json: expect '}' or ',' at \(nextNext) = '\(string[nextNext])'")
            }
        }
        
        // invalid json
        throw ParseError("invalid json: expect '}' at \(cursor). ")
    }
}
