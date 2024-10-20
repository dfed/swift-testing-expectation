// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swift-testing-expectation",
	platforms: [
		.macOS(.v13),
		.iOS(.v16),
		.tvOS(.v16),
		.watchOS(.v9),
		.macCatalyst(.v16),
		.visionOS(.v1),
	],
	products: [
		.library(
			name: "TestingExpectation",
			targets: ["TestingExpectation"]
		),
	],
	targets: [
		.target(
			name: "TestingExpectation",
			dependencies: [],
			swiftSettings: [
				.swiftLanguageMode(.v6),
			]
		),
		.testTarget(
			name: "TestingExpectationTests",
			dependencies: ["TestingExpectation"],
			swiftSettings: [
				.swiftLanguageMode(.v6),
			]
		),
	]
)
