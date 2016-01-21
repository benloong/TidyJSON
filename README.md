# TidyJSON
A neat and tidy JSON package run on all Swift platforms (Linux, iOS, OS X)

## Goals 
- [x] simple, neat and tidy json lib
- [x] only dependent to builtin types
- [x] compatible with all Swift platforms (Linux, iOS, OS X)
- [x] concise usage
- [ ] fully tested

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

### Dump to String 
```swift
let json2 = JSON.parse("{\"key\" : \" \\u0041334 \\n \\t \\\" \"}")
print(json2.dump())
// {"key":" A334 \n \t \" "}
```

## License
MIT license