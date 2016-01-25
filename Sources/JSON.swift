

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
    * Empty json or invalid json with parse error message
    */
    case None(_: Swift.String?)
    
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
    
    init() {
        self = .None(nil)
    }
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
            case .Number(let x): return Int(x)
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
    public func removeAtIndex(index: Int) -> JSON {
        switch self {
            case .Array(let x): return x.array.removeAtIndex(index)
            default: return JSON()
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
                default: return JSON()
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
                default: return JSON()
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
    * parse json from string, return nil and error message if parse error occurred 
    */
    public static func parse(string: Swift.String) -> (JSON?, Swift.String?) {
        let (json, _) = parseValue(string, index: string.startIndex)
        switch json {
            case .None(let error): return (nil, error)
            default: return (json, nil)
        }
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
            case .None : string.appendContentsOf("None")
            case .Null : string.appendContentsOf("null")
            case .Boolean(let b) : string.appendContentsOf(b.description)
            case .Number(let n) : string.appendContentsOf(n.description)
            case .String(let s) : dumpString(&string, jsonString: s)
            case .Array(let a) : dumpArray(&string, array: a.array)
            case .Object(let o) : dumpObject(&string, object: o.dict)
        }
    }
    
    func dumpArray(inout string: Swift.String, array: [JSON]) {
        let comma : Character = ","
        let open : Character = "["
        let close : Character = "]"
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
        let comma : Character = ","
        let open : Character = "{"
        let close : Character = "}"
        let colon : Character = ":"
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
        let rs : Character = "\\"
        let s : Character = "/"
        let q : Character = "\""
        //Fixme let b : Character = "b"
        //Fixme let f : Character = "f"
        let n : Character = "n"
        let r : Character = "r"
        let t : Character = "t"
        
        string.append(q)
        for ch in jsonString.characters {
            switch ch {
                case "\\" : string.append(rs); string.append(rs)
                case "/" : string.append(rs); string.append(s)
                case "\"" : string.append(rs); string.append(q)
                case "\n" : string.append(rs); string.append(n)
                case "\r" : string.append(rs); string.append(r)
                case "\t" : string.append(rs); string.append(t)
                default: string.append(ch)
            }
        }
        string.append(q)
    }
}

//MARK: - Parser internal

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

private func _parseString(string: String, index: String.Index) -> (String?, String.Index, String?) {
     // skip first '\"' character
    var cursor = eatWhiteSpace(string, index: index).advancedBy(1)
    
    
    let rs : Character = "\\"
    let s : Character = "/"
    let q : Character = "\""
    //Fixme let b : Character = "\b"
    //Fixme let f : Character = "\f"
    let n : Character = "\n"
    let r : Character = "\r"
    let t : Character = "\t"
    
    var result = ""
    while cursor != string.endIndex {
        switch string[cursor] {
            case "\\":  
                cursor = cursor.advancedBy(1)
                // invalid json format
                if  cursor == string.endIndex {
                    return (nil, cursor, "invalid json: not expect end at \(cursor)")
                }
                let ch = string[cursor]
                switch ch {
                    case "\\": result.append(rs)
                    case "/": result.append(s)
                    case "\"": result.append(q)
                    //case "b": result.append(b)
                    //case "f": result.append(f)
                    case "n": result.append(n)
                    case "r": result.append(r)
                    case "t": result.append(t)
                    case "u": 
                        // parse unicode scalar hex digit
                        // skip 'u'
                        cursor = cursor.advancedBy(1)
                        if(cursor.distanceTo(string.endIndex) > 4 ) {
                            let hexEnd = cursor.advancedBy(4)
                            if let unicode = Int(string[Range(start:cursor, end:hexEnd)], radix: 16) {
                                result.append(UnicodeScalar(unicode))
                                cursor = hexEnd.advancedBy(-1)
                            }
                            else {
                                // invalid json 
                                return (nil, cursor, "invalid json: illegal unicode hex digit at \(cursor) ")
                            }
                            
                        }
                        else {
                            // invalid json format
                            return (nil, cursor, "invalid json: illegal unicode hex digit at \(cursor)")
                        }
                    
                    // invalid json format
                    default: return (nil, cursor, "invalid json: illegal character \(ch) after '\\' at \(cursor)")
                }
            
            case "\"": return (result, cursor.advancedBy(1), nil)
            default: result.append(string[cursor])
        }
        cursor = cursor.advancedBy(1)
    }
    return (nil, cursor, "invalid json: expect character \" at \(cursor)")
}

/**
* skip all whitespace 
*/
private func eatWhiteSpace(string: String, index: String.Index) -> String.Index {
    var cursor = index
    while (cursor != string.endIndex) {
        switch string[cursor] {
            case " ", "\t", "\n", "\r": cursor = cursor.advancedBy(1)
            default: return cursor 
        }
    }
    return cursor
}

/**
* get next token and index of this token
*/
private func nextToken(string: String, index: String.Index) -> (Token, String.Index) {
    var cursor = eatWhiteSpace(string, index: index)
    var token : Token = .None
    
    if cursor != string.endIndex {
        let char = string[cursor]
        switch char {
            case "{" : token = .CurlyOpen 
            case "}" : token = .CurlyClose
            case "[" : token = .SquareOpen
            case "]" : token = .SquareClose
            case "," : token = .Comma
            case ":" : token = .Colon
            case "\"" : token = .String
            case "f" : token = .False
            case "t" : token = .True
            case "n" : token = .Null
            case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" : token = .Number
            default: break
        }
    }
    
    cursor = eatWhiteSpace(string, index: cursor)
    return (token, cursor)
}

private func getLastIndexOfNumber(string: String, index: String.Index) -> String.Index {
    for lastIndex in Range(start: index, end: string.endIndex) {
        switch (string[lastIndex]) {
            // -4.2e3  +12E4
            case "-", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "e", "E", ".": continue
            default: return lastIndex
        }
    }
    return string.endIndex 
}

private func parseValue(string: String, index: String.Index) -> (JSON, String.Index) {
    let (token, cursor) = nextToken(string, index: index)

    switch token {
        case .CurlyOpen : return parseObject(string, index: cursor)
        case .SquareOpen : return parseArray(string, index: cursor)
        case .Number : return parseNumber(string, index: cursor)
        case .String : return parseString(string, index: cursor)
        case .False: return parseFalse(string, index: cursor)
        case .True: return parseTrue(string, index: cursor)
        case .Null: return parseNull(string, index: cursor)
        default: break
    }
    return (.None("invalid json: character invalid at \(cursor)"), cursor)
}

private func parseString(string: String, index: String.Index) -> (JSON, String.Index) {
    let (s, cursor, err) = _parseString(string, index: index)
    if  let json = s {
        return (JSON(json), cursor)
    }
    return (.None(err), cursor)
}

private func parseNumber(string: String, index: String.Index) -> (JSON, String.Index) {
    let cursor = eatWhiteSpace(string, index: index)
    let lastIndex = getLastIndexOfNumber(string, index: cursor)
    let substr = string[Range(start: cursor, end: lastIndex)]
    let number = Double(substr) ?? 0
    return (JSON(floatLiteral: number), lastIndex)
}

private func parseNull(string: String, index: String.Index) -> (JSON, String.Index) {
    let cursor = eatWhiteSpace(string, index: index)
    
    guard cursor.distanceTo(string.endIndex) > 3 else {
        // invalid json
        return (.None("invalid json: expect 'null' at \(cursor)"), cursor)
    }
    
    if  string[cursor] == "n" 
        && string[cursor.advancedBy(1)] == "u"
        && string[cursor.advancedBy(2)] == "l"
        && string[cursor.advancedBy(3)] == "l" {
            return (nil, cursor.advancedBy(4))
    }
    // invalid json
    return (.None("invalid json: expect 'null' at \(cursor)"), cursor)
}

private func parseTrue(string: String, index: String.Index) -> (JSON, String.Index) {
    let cursor = eatWhiteSpace(string, index: index)
    
    guard cursor.distanceTo(string.endIndex) > 3 else {
        // invalid json
        return (.None("invalid json: expect 'true' at \(cursor)"), cursor)
    }
    
    if  string[cursor] == "t" 
        && string[cursor.advancedBy(1)] == "r"
        && string[cursor.advancedBy(2)] == "u"
        && string[cursor.advancedBy(3)] == "e" {
            return (true, cursor.advancedBy(4))
    }
    
    // invalid json
    return (.None("invalid json: expect 'true' at \(cursor)"), cursor)
}

private func parseFalse(string: String, index: String.Index) -> (JSON, String.Index) {
    let cursor = eatWhiteSpace(string, index: index)
    
    guard cursor.distanceTo(string.endIndex) > 4 else {
        // invalid json
        return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
    }
    
    if  string[cursor] == "f" 
        && string[cursor.advancedBy(1)] == "a"
        && string[cursor.advancedBy(2)] == "l"
        && string[cursor.advancedBy(3)] == "s" 
        && string[cursor.advancedBy(4)] == "e" {
            return (false, cursor.advancedBy(5))
    }
    // invalid json
    return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
}

private func parseArray(string: String, index: String.Index) -> (JSON, String.Index) {
    var cursor = eatWhiteSpace(string, index: index)
    
    guard string[cursor] == "[" else {
        // invalid json "[" start array
        return (.None("invalid json: expect '[' at \(cursor)"), cursor)
    }
    
    // skip "["
    cursor = cursor.advancedBy(1)
    cursor = eatWhiteSpace(string, index: cursor)
    
    var array = [JSON]()
    
    guard string[cursor] != "]" else {
        // empty array "[]" early return
        return (JSON(array), cursor.advancedBy(1))
    }
    
    while cursor != string.endIndex {
        // parse value 
        let (json, next) = parseValue(string, index: cursor)
        switch json {
            // parse error
            case .None(let err): return (.None(err), next)
            default: break
        }
        cursor = next
        array.append(json)
        
        // next token  "," or "]"
        
        let (token, nextNext) = nextToken(string, index: cursor)
        switch token {
            // "," parse next value
            case .Comma: cursor = nextNext.advancedBy(1)
            // "]" end array
            case .SquareClose: return (JSON(array), cursor.advancedBy(1))
            // invalid json 
            default: return (.None("invalid json: expect ']' or ',' at \(nextNext)"), nextNext)
        }
    }
    
    // invalid json
    return (.None("invalid json: expect ']' or ',' at \(cursor)"), cursor)
}

private func parseObject(string: String, index: String.Index) -> (JSON, String.Index) {
    var cursor = eatWhiteSpace(string, index: index)
    
    guard string[cursor] == "{" else {
        // invalid json "{" start array
        return (.None("invalid json: expect '{' at \(cursor). "), cursor)
    }
    
    // skip "{"
    cursor = cursor.advancedBy(1)
    cursor = eatWhiteSpace(string, index: cursor)
    
    var object : [String : JSON] = [:]
    
    guard string[cursor] != "}" else {
        // empty object "{}" early return
        return (JSON(object), cursor.advancedBy(1))
    }
    
    while cursor != string.endIndex {
        let (_key, afterKey, err) = _parseString(string, index: cursor)
        guard let key = _key else {
            // parse key error, invalid json
            return (.None(err), cursor)
        }
        cursor = afterKey
        let (token1, tokenIndex) = nextToken(string, index: cursor)
        switch token1 {
            case .Colon: break
            
            // not match expect ":", invalid json
            default: return (.None("invalid json: expect ':' at \(tokenIndex)"), cursor)
        }
        cursor = tokenIndex.advancedBy(1)
        // parse value 
        let (json, next) = parseValue(string, index: cursor)
        switch json {
            // parse error, invalid json
            case .None(let err): return (.None(err), cursor)
            default: break
        }
        cursor = next
        object[key] = json
        
        // next token  "," or "}"
        let (token, nextNext) = nextToken(string, index: cursor)
        switch token {
            // "," parse next value
            case .Comma: cursor = nextNext.advancedBy(1)
            // "}" end object
            case .CurlyClose: return (JSON(object), cursor.advancedBy(1))
            // not expected token, invalid json 
            default: return (.None("invalid json: expect '}' or ',' at \(nextNext). "), nextNext)
        }
    }
    
    // invalid json
    return (.None("invalid json: expect '}' at \(cursor). "), cursor)
}
