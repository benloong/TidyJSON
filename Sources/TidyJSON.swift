

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
        let (json, _) = Parser(string).parse()
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

//MARK: - Parser internal
struct Parser {
    let string: [UnicodeScalar]
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
    
    let rs : UnicodeScalar = "\\"
    let s : UnicodeScalar = "/"
    let q : UnicodeScalar = "\""
    let b : UnicodeScalar = "\u{8}"
    let f : UnicodeScalar = "\u{c}"
    let n : UnicodeScalar = "\n"
    let r : UnicodeScalar = "\r"
    let t : UnicodeScalar = "\t"
    let _b : UnicodeScalar = "b"
    let _f : UnicodeScalar = "f"
    let _n : UnicodeScalar = "n"
    let _r : UnicodeScalar = "r"
    let _t : UnicodeScalar = "t"
    let _u : UnicodeScalar = "u"
    let _l : UnicodeScalar = "l"
    let _a : UnicodeScalar = "a"
    let _s : UnicodeScalar = "s"
    let _space : UnicodeScalar = " "
    let co : UnicodeScalar = "{"
    let cc : UnicodeScalar = "}"
    let so : UnicodeScalar = "["
    let sc : UnicodeScalar = "]"
    let comma : UnicodeScalar = ","
    let colon : UnicodeScalar = ":"
    let minus : UnicodeScalar = "-"
    let plus : UnicodeScalar = "+"
    let _0 : UnicodeScalar = "0"
    let _1 : UnicodeScalar = "1"
    let _2 : UnicodeScalar = "2"
    let _3 : UnicodeScalar = "3"
    let _4 : UnicodeScalar = "4"
    let _5 : UnicodeScalar = "5"
    let _6 : UnicodeScalar = "6"
    let _7 : UnicodeScalar = "7"
    let _8 : UnicodeScalar = "8"
    let _9 : UnicodeScalar = "9"
    let _E : UnicodeScalar = "E"
    let _e : UnicodeScalar = "e"
    let dot : UnicodeScalar = "."
    
    init(_ str: String) {
        string = str.unicodeScalars.flatMap(){ $0 }
    }
    
    func parse() -> (JSON, Int) {
        return self.parseValue(0)
    }
    
    private func _parseString(index: Int) -> (String?, Int, String?) {
         // skip first '\"' character
        var cursor = eatWhiteSpace(index).successor()
        
        var result = ""
        while cursor != string.endIndex {
            switch string[cursor] {
                case rs:
                    cursor = cursor.successor()
                    // invalid json format
                    if  cursor == string.endIndex {
                        return (nil, cursor, "invalid json: not expect end at \(cursor)")
                    }
                    let ch = string[cursor]
                    switch ch {
                        case rs: result.append(rs)
                        case s: result.append(s)
                        case q: result.append(q)
                        case _b: result.append(b)
                        case _f: result.append(f)
                        case _n: result.append(n)
                        case _r: result.append(r)
                        case _t: result.append(t)
                        case _u:
                            // parse unicode scalar hex digit
                            // skip 'u'
                            var hex = ""
                            
                            cursor = cursor.successor()
                            guard cursor != string.endIndex else {
                                return (nil, cursor, "invalid json: illegal unicode hex digit at \(cursor) ")
                            }
                            hex.append(string[cursor])
                            
                            cursor = cursor.successor()
                            guard cursor != string.endIndex else {
                                return (nil, cursor, "invalid json: illegal unicode hex digit at \(cursor) ")
                            }
                            hex.append(string[cursor])
                            
                            cursor = cursor.successor()
                            guard cursor != string.endIndex else {
                                return (nil, cursor, "invalid json: illegal unicode hex digit at \(cursor) ")
                            }
                            hex.append(string[cursor])
                            
                            cursor = cursor.successor()
                            guard cursor != string.endIndex else {
                                return (nil, cursor, "invalid json: illegal unicode hex digit at \(cursor) ")
                            }
                            hex.append(string[cursor])
                            
                            if let unicode = Int(hex, radix: 16) {
                                result.append(UnicodeScalar(unicode))
                            }
                        
                        // invalid json format
                        default: return (nil, cursor, "invalid json: illegal character \(ch) after '\\' at \(cursor)")
                    }
                
                case q: return (result, cursor.successor(), nil)
                default: result.append(string[cursor])
            }
            cursor = cursor.successor()
        }
        return (nil, cursor, "invalid json: expect character \" at \(cursor)")
    }

    /**
    * skip all whitespace 
    */
    private func eatWhiteSpace(index: Int) -> Int {
        var cursor = index
        while (cursor != string.endIndex) {
            switch string[cursor] {
                case _space, t, n, r: cursor = cursor.successor()
                default: return cursor 
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
                case co: token = .CurlyOpen
                case cc: token = .CurlyClose
                case so: token = .SquareOpen
                case sc: token = .SquareClose
                case comma: token = .Comma
                case colon: token = .Colon
                case q: token = .String
                case _f: token = .False
                case _t: token = .True
                case _n: token = .Null
                case minus, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9: token = .Number
                default: break
            }
        }
        
        cursor = eatWhiteSpace(cursor)
        return (token, cursor)
    }

    private func getLastIndexOfNumber(index: Int) -> Int {
        for lastIndex in Range(start: index, end: string.endIndex) {
            switch (string[lastIndex]) {
                // -4.2e3  +12E4
                case minus, plus, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _e, _E, dot: continue
                default: return lastIndex
            }
        }
        return string.endIndex 
    }

    private func parseValue(index: Int) -> (JSON, Int) {
        let (token, cursor) = nextToken(index)

        switch token {
            case .CurlyOpen : return parseObject(cursor)
            case .SquareOpen : return parseArray(cursor)
            case .Number : return parseNumber(cursor)
            case .String : return parseString(cursor)
            case .False: return parseFalse(cursor)
            case .True: return parseTrue(cursor)
            case .Null: return parseNull(cursor)
            default: break
        }
        return (.None("invalid json: character invalid at \(cursor)"), cursor)
    }

    private func parseString(index: Int) -> (JSON, Int) {
        let (s, cursor, err) = _parseString(index)
        if  let json = s {
            return (JSON(json), cursor)
        }
        return (.None(err), cursor)
    }

    private func parseNumber(index: Int) -> (JSON, Int) {
        let cursor = eatWhiteSpace(index)
        let lastIndex = getLastIndexOfNumber(cursor)
        var substr = ""
        for x in  cursor..<lastIndex {
            substr.append(string[x])
        }
        if  let number = Double(substr) {
            return (JSON(floatLiteral: number), lastIndex)
        }
        return (.None("invalid json: \(substr) is not a valid number."), lastIndex)
    }

    private func parseNull(index: Int) -> (JSON, Int) {
        var cursor = eatWhiteSpace(index)
        
        guard cursor != string.endIndex && string[cursor] == _n else {
            return (.None("invalid json: expect 'null' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _u else {
            return (.None("invalid json: expect 'null' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _l else {
            return (.None("invalid json: expect 'null' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _l else {
            return (.None("invalid json: expect 'null' at \(cursor)"), cursor)
        }
        
        return (nil, cursor.successor())
    }

    private func parseTrue(index: Int) -> (JSON, Int) {
        var cursor = eatWhiteSpace(index)
        
        guard cursor != string.endIndex && string[cursor] == _t else {
            return (.None("invalid json: expect 'true' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _r else {
            return (.None("invalid json: expect 'true' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _u else {
            return (.None("invalid json: expect 'true' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _e else {
            return (.None("invalid json: expect 'true' at \(cursor)"), cursor)
        }
        
        return (true, cursor.successor())
    }

    private func parseFalse(index: Int) -> (JSON, Int) {
        var cursor = eatWhiteSpace(index)
        
        guard cursor != string.endIndex && string[cursor] == _f else {
            return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _a else {
            return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _l else {
            return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _s else {
            return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
        }
        cursor = cursor.successor()
        guard cursor != string.endIndex && string[cursor] == _e else {
            return (.None("invalid json: expect 'false' at \(cursor)"), cursor)
        }
        return (false, cursor.successor())
    }

    private func parseArray(index: Int) -> (JSON, Int) {
        var cursor = eatWhiteSpace(index)
        
        guard string[cursor] == so else {
            // invalid json "[" start array
            return (.None("invalid json: expect '[' at \(cursor)"), cursor)
        }
        
        // skip "["
        cursor = cursor.successor()
        cursor = eatWhiteSpace(cursor)
        
        var array = [JSON]()
        
        guard string[cursor] != sc else {
            // empty array "[]" early return
            return (JSON(array), cursor.successor())
        }
        
        while cursor != string.endIndex {
            // parse value 
            let (json, next) = parseValue(cursor)
            switch json {
                // parse error
                case .None(let err): return (.None(err), next)
                default: break
            }
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
                default: return (.None("invalid json: expect ']' or ',' at \(nextNext)"), nextNext)
            }
        }
        
        // invalid json
        return (.None("invalid json: expect ']' or ',' at \(cursor)"), cursor)
    }

    private func parseObject(index: Int) -> (JSON, Int) {
        var cursor = eatWhiteSpace(index)
        
        guard string[cursor] == co else {
            // invalid json "{" start array
            return (.None("invalid json: expect '{' at \(cursor). "), cursor)
        }
        
        // skip "{"
        cursor = cursor.successor()
        cursor = eatWhiteSpace(cursor)
        
        var object : [String : JSON] = [:]
        
        guard string[cursor] != cc else {
            // empty object "{}" early return
            return (JSON(object), cursor.successor())
        }
        
        while cursor != string.endIndex {
            let (_key, afterKey, err) = _parseString(cursor)
            guard let key = _key else {
                // parse key error, invalid json
                return (.None(err), cursor)
            }
            cursor = afterKey
            let (token1, tokenIndex) = nextToken(cursor)
            switch token1 {
                case .Colon: break
                
                // not match expect ":", invalid json
                default: return (.None("invalid json: expect ':' at \(tokenIndex)"), cursor)
            }
            cursor = tokenIndex.successor()
            // parse value 
            let (json, next) = parseValue(cursor)
            switch json {
                // parse error, invalid json
                case .None(let err): return (.None(err), cursor)
                default: break
            }
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
                default: return (.None("invalid json: expect '}' or ',' at \(nextNext) = '\(string[nextNext])'"), nextNext)
            }
        }
        
        // invalid json
        return (.None("invalid json: expect '}' at \(cursor). "), cursor)
    }
}
