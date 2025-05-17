// MIT License
//
// Copyright (c) 2024 Dan Federman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Testing

@testable import TestingExpectation

struct ExpectationTests {
	@Test
	func fulfill_triggersExpectation() async {
		await confirmation { confirmation in
			let systemUnderTest = Expectation(
				expectedCount: 1,
				expect: { expectation, _, _ in
					#expect(expectation)
					confirmation()
				}
			)
			await systemUnderTest.fulfill().value
		}
	}

	@Test
	func fulfill_triggersExpectationOnceWhenCalledTwiceAndExpectedCountIsTwo() async {
		await confirmation { confirmation in
			let systemUnderTest = Expectation(
				expectedCount: 2,
				expect: { expectation, _, _ in
					#expect(expectation)
					confirmation()
				}
			)
			await systemUnderTest.fulfill().value
			await systemUnderTest.fulfill().value
		}
	}

	@Test
	func fulfill_triggersExpectationWhenExpectedCountIsZero() async {
		await confirmation { confirmation in
			let systemUnderTest = Expectation(
				expectedCount: 0,
				expect: { expectation, _, _ in
					#expect(!expectation)
					confirmation()
				}
			)
			await systemUnderTest.fulfill().value
		}
	}

	@Test
	func fulfillment_doesNotWaitIfAlreadyFulfilled() async {
		let systemUnderTest = Expectation(expectedCount: 0)
		await systemUnderTest.fulfillment(within: .seconds(10))
	}

	@MainActor // Global actor ensures Task ordering.
	@Test
	func fulfillment_waitsForFulfillment() async {
		let systemUnderTest = Expectation(expectedCount: 1, conditionFulfillmentAwaited: false)
		var hasFulfilled = false
		let wait = Task {
			await systemUnderTest.fulfillment(within: .seconds(10))
			#expect(hasFulfilled)
		}
		Task {
			systemUnderTest.fulfill()
			hasFulfilled = true
		}
		await wait.value
	}

	@Test
	func fulfillment_triggersFalseExpectationWhenItTimesOut() async {
		await confirmation { confirmation in
			let systemUnderTest = Expectation(
				expectedCount: 1,
				expect: { expectation, _, _ in
					#expect(!expectation)
					confirmation()
				}
			)
			await systemUnderTest.fulfillment(within: .zero)
		}
	}

	@Test
	func deinit_triggersTrueExpectationWhenNotAwaited() async {
		let expect: @Sendable (Bool, Comment?, SourceLocation) -> Void = { _, _, _ in }
		expect(true, nil, #_sourceLocation) // Force code coverage to cover the empty closure.
		await confirmation { confirmation in
			let unmanagedSystemUnderTest = Unmanaged.passRetained(Expectation(
				expectedCount: 0,
				expect: expect,
				precondition: { condition, message, _, _ in
					_ = message() // Force code coverage to cover the creation of the message.
					#expect(condition())
					confirmation()
				}
			))
			await unmanagedSystemUnderTest.takeUnretainedValue().fulfillment(within: .zero)
			unmanagedSystemUnderTest.release() // Force the system under test to deinit.
		}
	}

	@Test
	func deinit_triggersFalseExpectationWhenNotAwaited() async {
		let expect: @Sendable (Bool, Comment?, SourceLocation) -> Void = { _, _, _ in }
		expect(true, nil, #_sourceLocation) // Force code coverage to cover the empty closure.
		await confirmation { confirmation in
			_ = Expectation(
				expectedCount: 1,
				expect: expect,
				precondition: { condition, message, _, _ in
					_ = message() // Force code coverage to cover the creation of the message.
					#expect(!condition())
					confirmation()
				}
			)
		}
	}
}
