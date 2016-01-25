# TidyJSON
A neat and tidy JSON package run on all Swift platforms (Linux, iOS, OS X)

Currently, JSON Array and Object are immutable

## Goals 
- [x] simple, neat and tidy json lib
- [x] only dependent to builtin types
- [x] compatible with all Swift platforms (Linux, iOS, OS X)
- [x] concise usage
- [ ] boxing dict and array type for mutating data
- [ ] modify json via subscript operator
- [x] fully tested
- [x] better parse error report
- [ ] Swift Package Manager, CocoaPods, Carthage support

## Usage 

### Literal Convertible
```swift
let jsonFalse : JSON = false
let jsonTrue : JSON = true
let jsonNull : JSON = nil
let jsonNumber : JSON = 1.2e-2
let jsonString : JSON = "hello swift"
let jsonArray : JSON = [12, "string", false, nil, true, ["nested array", 12, 1.2], ["nested dict": nil]]
let json : JSON = ["key":false, "key2":true, "key3":[1, "hello", 3, "world", ["key4":nil, "key5":12.03, "key6":12E-2, "key7": -12e-2]]]
```

### Parse from String
```swift
let json1 = JSON.parse("{\"key\" : false }")
if let b = json1["key"].bool {
    print(b)
}
/* out
false
*/

let json2 = JSON.parse("{\"key\" : [\" \\u0041334 \\n \\t \\\" \"]}")

if let x = json2["key"][0].string {
    print(x)
}
/* out
 A334 
         " 
*/

```

### Loop

```swift
let jsonArray : JSON = [12, "string", false, nil, true]
// for Array, key is string of current index
for (k, v) in jsonArray {
    print("key: \(k), value: \(v)")
}
/* 
key: 0, value: Number(12.0)
key: 1, value: String("string")
key: 2, value: Boolean(false)
key: 3, value: Null
key: 4, value: Boolean(true)
*/

let json : JSON = ["key1":false, "key2":true, "key3": 123, "key4": "hello"]

for (k, v) in json {
    print("key: \(k), value: \(v)")
}
/*
key: key, value: Boolean(false)
key: key2, value: Boolean(true)
key: key4, value: String("hello")
key: key1, value: Boolean(false)
key: key3, value: Number(123.0)
*/
```

### Dump to String 
```swift
let json2 = JSON.parse("{\"key\" : \" \\u0041334 \\n \\t \\\" \"}")
print(json2.dump())
// {"key":" A334 \n \t \" "}
```

## Test

On Linux platform you need install [`XCTest`](https://github.com/apple/swift-corelibs-xctest)

After install `XCTest`, run `sh run_test.sh`

## License
MIT license
