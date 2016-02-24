# TidyJSON

TidyJSON is a neat and tidy JSON package run on all Swift platforms (Linux, iOS, OS X, tvOS, watchOS)

[![Build Status](https://travis-ci.org/benloong/TidyJSON.svg?branch=master)](https://travis-ci.org/benloong/TidyJSON)

## Goals 
- [x] simple, neat and tidy json lib
- [x] safe static typed without `Any` or `AnyObject`
- [x] performance
- [x] pure Swift, only dependent to builtin types
- [x] compatible with all Swift platforms (Linux, iOS, OS X, tvOS, watchOS)
- [x] concise usage
- [x] boxing dict and array type for mutating data
- [x] modify json via subscript operator
- [x] fully tested
- [x] better parse error report
- [x] Swift Package Manager, Carthage support

## Usage 

### Literal Convertible

Literal value can be type safe converted to TidyJSON.JSON like this:

```swift
let jsonFalse : JSON = false
let jsonTrue : JSON = true
let jsonNull : JSON = nil
let jsonNumber : JSON = 1.2e-2
let jsonString : JSON = "hello swift"
let jsonArray : JSON = [12, "string", false, nil, true, ["nested array", 12, 1.2], ["nested dict": nil]]
let json : JSON = ["key":false, "key2":true, "key3":[1, "hello", 3, "world", ["key4":nil, "key5":12.03, "key6":12E-2, "key7": -12e-2]]]
```

### Access value

Get and Set value via Subscripts:

```swift 
var json : JSON = []
// []

let child :JSON = "string"
json.append(child)
// ["string"]

json[0] = "STRING"
// ["STRING"]

json.append(JSON([]))
// ["STRING", []]

json[1].append(JSON("hello"))
// ["STRING", ["hello"]]

json[1][0] = "world" 
// ["STRING", ["world"]]

json[1].removeAtIndex(0)  
// ["STRING", []]

json.removeAtIndex(1)
// ["STRING"]

var json1 : JSON = [:]
// {}
json1["hello"] = false 
// {"hello":false}

json1["world"] = true
// {"hello":false, "world":true}

// remove a key
json1["hello"] = nil
// {"world":true}

json1["world"] = [1,2,3]
// {"world":[1,2,3]}
```

### Parse from String
```swift
let json1 = try! JSON.parse("{\"key\" : false }")
if let b = json1["key"].bool {
    print(b)
}
/*
false
*/

let json2 = try! JSON.parse("{\"key\" : [\" \\u0041334 \\n \\t \\\" \"]}")

if let x = json2["key"][0].string {
    print(x)
}
/*
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
let json2 = try! JSON.parse("{\"key\" : \" \\u0041334 \\n \\t \\\" \"}")
print(json2.dump())
// {"key":" A334 \n \t \" "}
```

## Test

On Linux platform you need install [`XCTest`](https://github.com/apple/swift-corelibs-xctest)

After install `XCTest`, run `sh run_test.sh`

## Integration

#### Carthage

To integrate TidyJSON into your Xcode project using Carthage, specify it in your Cartfile:

`github "benloong/TidyJSON"`

#### Swift Package Manager

Currently support Swift Package Manager to install TidyJSON by adding the proper description to your Package.swift file:

```swift 
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/benloong/TidyJSON.git", majorVersion: 1)
    ]
)
```

## License
MIT license
