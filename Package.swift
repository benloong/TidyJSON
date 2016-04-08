import PackageDescription

let package = Package(
    name: "TidyJSON",
    dependencies: [
        .Package(url: "https://github.com/crossroadlabs/Boilerplate.git", majorVersion: 0),
        .Package(url: "https://github.com/crossroadlabs/Foundation3.git", majorVersion: 0),
        .Package(url: "https://github.com/crossroadlabs/XCTest3.git", majorVersion: 0)
    ]
)
