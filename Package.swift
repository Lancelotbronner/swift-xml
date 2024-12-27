// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-xml",
    products: [
        .library(name: "SwiftXML", targets: ["SwiftXML"]),
    ],
    targets: [
        .target(name: "SwiftXML"),

        .testTarget(name: "SwiftXMLTests", dependencies: ["SwiftXML"]),
    ]
)
