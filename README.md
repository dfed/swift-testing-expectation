# swift-testing-expectation
[![CI Status](https://img.shields.io/github/actions/workflow/status/dfed/swift-testing-expectation/ci.yml?branch=main)](https://github.com/dfed/swift-testing-expectation/actions?query=workflow%3ACI+branch%3Amain)
[![codecov](https://codecov.io/gh/dfed/swift-testing-expectation/branch/main/graph/badge.svg?token=nZBHcZZ63F)](https://codecov.io/gh/dfed/swift-testing-expectation)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdfed%2Fswift-testing-expectation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/dfed/swift-testing-expectation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdfed%2Fswift-testing-expectation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/dfed/swift-testing-expectation)

Create an asynchronous expectation in Swift Testing

## Testing with asynchronous expectations

The [Swift Testing](https://developer.apple.com/documentation/testing/testing-asynchronous-code) framework vends a [confirmation](https://developer.apple.com/documentation/testing/confirmation(_:expectedcount:isolation:sourcelocation:_:)-5mqz2#) method which enables testing asynchronous code. However unlike [XCTest](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations)’s [XCTestExpectation](https://developer.apple.com/documentation/xctest/xctestexpectation), this `confirmation` must be confirmed before the confirmation’s `body` completes. Swift Testing has no out-of-the-box way to ensure that an expectation is fulfilled at some indeterminate point in the future.

This library provides `Expectation` and `Expectations` types that fill that gap, allowing you to wait for asynchronous events with a timeout.

## Usage Examples

### Basic Usage

The `Expectation` type allows you to wait for an asynchronous event:

```swift
@Test func methodEventuallyTriggersClosure() async {
    let expectation = Expectation()

    systemUnderTest.closure = { expectation.fulfill() }
    systemUnderTest.method()

    await expectation.fulfillment(within: .seconds(5))
}
```

### Multiple Fulfillments

You can specify how many times an expectation should be fulfilled:

```swift
@Test func methodTriggersClosureMultipleTimes() async {
    let expectation = Expectation(expectedCount: 3)

    systemUnderTest.repeatingClosure = { expectation.fulfill() }
    systemUnderTest.triggerMultipleTimes()

    await expectation.fulfillment(within: .seconds(5))
}
```

### Waiting for Multiple Expectations

The `Expectations` type makes it easy to wait for multiple expectations in parallel:

```swift
@Test func methodEventuallyTriggersClosures() async {
    let expectation1 = Expectation()
    let expectation2 = Expectation()
    let expectation3 = Expectation()

    systemUnderTest.closure1 = { expectation1.fulfill() }
    systemUnderTest.closure2 = { expectation2.fulfill() }
    systemUnderTest.closure3 = { expectation3.fulfill() }
    systemUnderTest.method()

    await Expectations(expectation1, expectation2, expectation3).fulfillment(within: .seconds(5))
}
```

### Handling Timeouts

If an expectation is not fulfilled within the specified duration, the test will fail:

```swift
@Test func methodWithTimeout() async {
    let expectation = Expectation()
    
    systemUnderTest.delayedClosure = { 
        Task {
            try? await Task.sleep(for: .seconds(10))
            expectation.fulfill()
        }
    }
    systemUnderTest.method()
    
    // This will fail if not fulfilled within 2 seconds
    await expectation.fulfillment(within: .seconds(2))
}
```

### Integration with Async/Await

Expectations work seamlessly with Swift's async/await patterns:

```swift
@Test func asyncMethodCompletion() async {
    let expectation = Expectation()
    
    Task {
        await systemUnderTest.performAsyncOperation()
        expectation.fulfill()
    }
    
    await expectation.fulfillment(within: .seconds(5))
}
```

## Installation

### Swift Package Manager

To install swift-testing-expectation in your project with [Swift Package Manager](https://github.com/apple/swift-package-manager), the following lines can be added to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/dfed/swift-testing-expectation", from: "0.1.0"),
]
```

### CocoaPods

To install swift-testing-expectation in your project with [CocoaPods](https://blog.cocoapods.org/CocoaPods-Specs-Repo), add the following to your `Podfile`:

```
pod 'TestingExpectation', '~> 0.1.0'
```

## Contributing

I’m glad you’re interested in swift-testing-expectation, and I’d love to see where you take it. Please read the [contributing guidelines](Contributing.md) prior to submitting a Pull Request.
