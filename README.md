# swift-testing-expectation
[![CI Status](https://img.shields.io/github/actions/workflow/status/dfed/swift-testing-expectation/ci.yml?branch=main)](https://github.com/dfed/swift-testing-expectation/actions?query=workflow%3ACI+branch%3Amain)
[![codecov](https://codecov.io/gh/dfed/swift-testing-expectation/branch/main/graph/badge.svg?token=nZBHcZZ63F)](https://codecov.io/gh/dfed/swift-testing-expectation)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdfed%2Fswift-testing-expectation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/dfed/swift-testing-expectation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdfed%2Fswift-testing-expectation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/dfed/swift-testing-expectation)

Making it easy to create an asynchronous expectation in Swift Testing

## Testing with asynchronous expectations

The [Swift Testing](https://developer.apple.com/documentation/testing/testing-asynchronous-code) vends a [confirmation](https://developer.apple.com/documentation/testing/confirmation(_:expectedcount:isolation:sourcelocation:_:)) method which enables testing asynchronous code. However unlike [XCTest](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations)’s [XCTestExpectation](https://developer.apple.com/documentation/xctest/xctestexpectation), this `confirmation` must be confirmed before the confirmation’s `body` completes. Swift Testing has no out-of-the-box way to ensure that an expectation is fulfilled at some indeterminate point in the future.

The `Expectation` vended from this library fills that gap:

```swift
@Test func testMethodCallEventuallyTriggersClosure() async {
	let expectation = Expectation()

	systemUnderTest.closure = { expectation.fulfill() }
	systemUnderTest.method()

	await expectation.fulfillment(within: .seconds(5))
}
```

## Requirements

* Xcode 16.0 or later.
* iOS 16 or later.
* tvOS 16 or later.
* watchOS 9 or later.
* macOS 13 or later.
* Swift 5.10 or later.

## Installation

### Swift Package Manager

To install swift-async-queue in your project with [Swift Package Manager](https://github.com/apple/swift-package-manager), the following lines can be added to your `Package.swift` file:

```swift
dependencies: [
	.package(url: "https://github.com/dfed/swift-testing-expectation", from: "0.1.0"),
]
```
