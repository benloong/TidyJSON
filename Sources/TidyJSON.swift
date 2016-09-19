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
extension JSON : ExpressibleByNilLiteral {
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

extension JSON : ExpressibleByBooleanLiteral {
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

extension JSON : ExpressibleByFloatLiteral {
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

extension JSON : ExpressibleByIntegerLiteral {
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
        case .Number(let x) where x.truncatingRemainder(dividingBy: 1) == 0: return Int(x)
        default: return nil
        }
    }
}

extension JSON : ExpressibleByStringLiteral {
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

extension JSON : ExpressibleByArrayLiteral {
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
    public func remove(at index: Int) -> JSON? {
        switch self {
        case .Array(let x): return x.array.remove(at: index)
        default: return nil
        }
    }
}

extension JSON : ExpressibleByDictionaryLiteral {
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
extension JSON : Sequence {
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

    public func makeIterator() -> JSON.Iterator {
        return JSON.Iterator(json: self)
    }

    //MARK: - generator
    public struct Iterator : IteratorProtocol {

        public typealias Element = (Swift.String, JSON)

        var arrayIterator: IndexingIterator<[JSON]>?
        var objectIterator: DictionaryIterator<Swift.String, JSON>?
        var index : Int = 0
        init(json: JSON) {
            switch json {
            case .Object(let obj): objectIterator = obj.dict.makeIterator()
            case .Array(let arr): arrayIterator = arr.array.makeIterator()
            default: break
            }
        }

        public mutating func next() -> Iterator.Element? {
            if let arrayElement =  arrayIterator?.next() {
                let _index = index
                index += 1
                return (Swift.String(_index), arrayElement)
            }
            if let objectElement = objectIterator?.next() {
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
#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
    public static func parse(string: Swift.String) throws -> JSON {
        if let data = string.data(using: Swift.String.Encoding.utf8) {
            return try parse(utf8: data)
        }
        return nil
    }
#elseif os(Linux)
    public static func parse(string: Swift.String) throws -> JSON {
        if let data = string.data(using: Swift.String.Encoding.utf8) {
    return try parse(utf8: data)
        }
        return nil
    }
#endif

    /**
     * parse JSON from utf8 endcoded bytes data buffer, return nil or valid JSON
     */
    public static func parse(utf8 data: Data) throws -> JSON {
        let buffer = data.withUnsafeBytes{ (ptr: UnsafePointer<UInt8>) -> UnsafePointer<UInt8> in
            return ptr
        }
//assumingMemoryBound(to:UInt8.self)//UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
        var parser = Parser(UnsafeBufferPointer(start: buffer, count: data.count))
        return try parser.parse().0
    }
}

//MARK: - String representation internal

extension JSON {
    public func dump() -> Swift.String {
        var result = ""
        JSON.dump(json: self, in: &result)
        return result
    }

    static func dump(json: JSON, in string: inout Swift.String) {
        switch json {
        case .Null : string.append("null")
        case .Boolean(let b) : dump(bool: b, in: &string)
        case .Number(let n) : dump(number: n, in: &string)
        case .String(let s) : dump(string: s, in: &string)
        case .Array(let a) : dump(array: a.array, in: &string)
        case .Object(let o) : dump(object: o.dict, in: &string)
        }
    }

    static func dump(bool: Bool, in string: inout Swift.String) {
        if bool {
            string.append("true")
        }
        else {
            string.append("false")
        }
    }

    static func dump(number: Double, in string: inout Swift.String) {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            string.append(Swift.String(Int(number)))
        }
        else {
            string.append(Swift.String(number))
        }
    }

    static func dump(array: [JSON], in string: inout Swift.String) {
        let comma = ","
        let open = "["
        let close = "]"
        string.append(open)
        for child in array {
            dump(json: child, in: &string)
            string.append(Swift.String(comma))
        }
        // remove last comma
        if array.count > 0 {
            string.remove(at: string.index(before: string.endIndex))
        }
        string.append(close)
        return
    }

    static func dump(object: [Swift.String : JSON], in string: inout Swift.String) {
        let comma = ","
        let open = "{"
        let close = "}"
        let colon = ":"
        string.append(open)
        for (k, v) in object {
            dump(string: k, in: &string)
            string.append(colon)
            dump(json: v, in: &string)
            string.append(comma)
        }
        // remove last comma
        if object.count > 0 {
            string.remove(at: string.index(before: string.endIndex))
        }
        string.append(close)
    }

    static func dump(string jsonString: Swift.String, in string: inout Swift.String) {
        let rs = "\\"
        let s = "/"
        let q = "\""
        let b = "b"
        let f = "f"
        let n = "n"
        let r = "r"
        let t = "t"

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

public struct ParseError : Error {
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
        return try self.parseValue(at: 0)
    }

    private mutating func _parseString(at index: Int) throws -> (String?, Int) {
        // skip first '\"' character
        var cursor = index + 1

        tempStringBuffer.removeAll(keepingCapacity: true)

        while cursor != string.endIndex {
            switch string[cursor] {
            case Parser.backslash:
                cursor = cursor + 1
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
                    cursor = cursor + 1
                    guard cursor.distance(to: string.endIndex) > 3 else {
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
                    UTF8.encode(unicode!, into: { self.tempStringBuffer.append($0) })

                    cursor = cursor.advanced(by: 3)
                    // invalid json format
                default: throw ParseError("invalid json: illegal character \(ch) after '\\' at \(cursor)")
                }

            case Parser.quote:
                tempStringBuffer.append(0)
                return (tempStringBuffer.withUnsafeBufferPointer(decodeString), cursor + 1)
            default: tempStringBuffer.append(string[cursor])
            }
            cursor = cursor + 1
        }
        throw ParseError("invalid json: expect character \" at \(cursor)")
    }

    private func decodeString(buffer: UnsafeBufferPointer<UInt8>) -> String? {
        let ptr = UnsafePointer(buffer.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buffer.count) { $0 })
        return String(validatingUTF8: ptr)
    }

    /**
     * skip all whitespace
     */
    private func eatWhiteSpace(from index: Int) -> Int {
        var cursor = index
        while (cursor != string.endIndex) {
            let ch = Parser.whitespaceTable[Int(string[cursor])]
            if ch == 0 {
                return cursor
            }
            else {
                cursor = cursor + 1
            }
        }
        return cursor
    }

    /**
     * get next token and index of this token
     */
    private func getNextToken(from index: Int) -> (Token, Int) {
        var cursor = eatWhiteSpace(from: index)
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

        cursor = eatWhiteSpace(from: cursor)
        return (token, cursor)
    }

    private mutating func parseValue(at index: Int) throws -> (JSON, Int) {
        let (token, cursor) = getNextToken(from: index)

        switch token {
        case .CurlyOpen : return try parseObject(at: cursor)
        case .SquareOpen : return try parseArray(at: cursor)
        case .Number : return try parseNumber(at: cursor)
        case .String : return try parseString(at: cursor)
        case .False: return try parseFalse(at: cursor)
        case .True: return try parseTrue(at: cursor)
        case .Null: return try parseNull(at: cursor)
        default: break
        }
        throw ParseError("invalid json: character invalid at \(cursor)")
    }

    private mutating func parseString(at index: Int) throws -> (JSON, Int) {
        let (s, cursor) = try _parseString(at: index)
        if let json = s {
            return (JSON(json), cursor)
        }
        throw ParseError("invalid json: expect string at \(index)")
    }

    func parseDouble(address: UnsafePointer<UInt8>) -> (Double, Int)? {
        let startPointer = UnsafePointer<Int8>(address.withMemoryRebound(to: Int8.self, capacity: 1){ $0 })
        let endPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
        defer { endPointer.deallocate(capacity: 1) }

        let result = strtod(startPointer, endPointer)
        let distance = startPointer.distance(to: endPointer[0]!)
        guard distance > 0 else {
            return nil
        }

        return (result, distance)
    }

    private mutating func parseNumber(at index: Int) throws -> (JSON, Int) {
        let cursor = index

        if let (double, distance) = parseDouble(address: string.baseAddress!.advanced(by: cursor)) {
            return (JSON(double), cursor + distance)
        }
        throw ParseError("invalid json: expect number at\(cursor).")
    }

    private func parseNull(at index: Int) throws -> (JSON, Int) {
        var cursor = index

        guard cursor != string.endIndex && string[cursor] == Parser.n else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.u else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.l else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.l else {
            throw ParseError("invalid json: expect 'null' at \(cursor)")
        }

        return (nil, cursor + 1)
    }

    private func parseTrue(at index: Int) throws -> (JSON, Int) {
        var cursor = index

        guard cursor != string.endIndex && string[cursor] == Parser.t else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.r else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.u else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.e else {
            throw ParseError("invalid json: expect 'true' at \(cursor)")
        }

        return (true, cursor + 1)
    }

    private func parseFalse(at index: Int) throws -> (JSON, Int) {
        var cursor = index

        guard cursor != string.endIndex && string[cursor] == Parser.f else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.a else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.l else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.s else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        cursor = cursor + 1
        guard cursor != string.endIndex && string[cursor] == Parser.e else {
            throw ParseError("invalid json: expect 'false' at \(cursor)")
        }
        return (false, cursor + 1)
    }

    private mutating func parseArray(at index: Int) throws -> (JSON, Int) {
        var cursor = index

        guard string[cursor] == Parser.leftbracket else {
            // invalid json "[" start array
            throw ParseError("invalid json: expect '[' at \(cursor)")
        }

        // skip "["
        cursor = cursor + 1
        cursor = eatWhiteSpace(from: cursor)

        var array = [JSON]()

        guard string[cursor] != Parser.rightbracket else {
            // empty array "[]" early return
            return (JSON(array), cursor + 1)
        }

        while cursor != string.endIndex {
            // parse value
            let (json, next) = try parseValue(at: cursor)

            cursor = next
            array.append(json)

            // next token  "," or "]"

            let (token, nextNext) = getNextToken(from: cursor)
            switch token {
                // "," parse next value
            case .Comma: cursor = nextNext + 1
                // "]" end array
            case .SquareClose: return (JSON(array), nextNext + 1)
                // invalid json
            default: throw ParseError("invalid json: expect ']' or ',' at \(nextNext)")
            }
        }

        // invalid json
        throw ParseError("invalid json: expect ']' or ',' at \(cursor)")
    }

    private mutating func parseObject(at index: Int) throws -> (JSON, Int) {
        var cursor = index

        guard string[cursor] == Parser.leftbrace else {
            // invalid json "{" start array
            throw ParseError("invalid json: expect '{' at \(cursor). ")
        }

        // skip "{"
        cursor = cursor + 1
        cursor = eatWhiteSpace(from: cursor)

        var object : [String : JSON] = [:]

        guard string[cursor] != Parser.rightbrace else {
            // empty object "{}" early return
            return (JSON(object), cursor + 1)
        }

        while cursor != string.endIndex {
            let (_key, afterKey) = try _parseString(at: eatWhiteSpace(from: cursor))
            guard let key = _key else {
                // parse key error, invalid json
                throw ParseError("invalid json: expect string at \(cursor)")
            }
            cursor = afterKey
            let (token1, tokenIndex) = getNextToken(from: cursor)
            switch token1 {
            case .Colon: break

                // not match expect ":", invalid json
            default: throw ParseError("invalid json: expect ':' at \(tokenIndex)")
            }
            cursor = tokenIndex + 1
            // parse value
            let (json, next) = try parseValue(at: cursor)

            cursor = next
            object[key] = json

            // next token  "," or "}"
            let (token, nextNext) = getNextToken(from: cursor)
            switch token {
                // "," parse next value
            case .Comma: cursor = nextNext + 1
                // "}" end object
            case .CurlyClose: return (JSON(object), nextNext + 1)
                // not expected token, invalid json
            default: throw ParseError("invalid json: expect '}' or ',' at \(nextNext) = '\(string[nextNext])'")
            }
        }

        // invalid json
        throw ParseError("invalid json: expect '}' at \(cursor). ")
    }
}
