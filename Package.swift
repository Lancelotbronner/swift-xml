// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-xml",
	products: [
		.library(name: "SwiftXML", targets: ["SwiftXML"]),
	],
	targets: [
		.target(name: "SwiftXML"),
		
		// .testTarget(name: "SwiftXMLTests", dependencies: ["SwiftXML"]),
	]
)
