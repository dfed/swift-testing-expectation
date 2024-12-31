// MIT License
//
// Copyright (c) 2025 Dan Federman
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

struct ExpectationsTests {
	@Test
	func test_fulfillment_doesNotWaitIfAlreadyFulfilled() async {
		let expectation = Expectation(expectedCount: 0)
		await Expectations(expectation).fulfillment(within: .seconds(10))
	}

	@MainActor // Global actor ensures Task ordering.
	@Test
	func test_fulfillment_waitsForFulfillmentOfSingleExpectation() async {
		let expectation = Expectation(expectedCount: 1)
		var hasFulfilled = false
		let wait = Task {
			await Expectations(expectation).fulfillment(within: .seconds(10))
			#expect(hasFulfilled)
		}
		Task {
			expectation.fulfill()
			hasFulfilled = true
		}
		await wait.value
	}

	@MainActor // Global actor ensures Task ordering.
	@Test
	func test_fulfillment_waitsForFulfillmentOfMultipleExpectations() async {
		let expectation1 = Expectation(expectedCount: 1)
		let expectation2 = Expectation(expectedCount: 1)
		let expectation3 = Expectation(expectedCount: 1)
		var hasFulfilled = false
		let wait = Task {
			await Expectations(expectation1).fulfillment(within: .seconds(10))
			#expect(hasFulfilled)
		}
		Task {
			expectation1.fulfill()
			expectation2.fulfill()
			expectation3.fulfill()
			hasFulfilled = true
		}
		await wait.value
	}

	@Test
	func test_fulfillment_triggersFalseExpectationWhenSingleExpectationTimesOut() async {
		await confirmation { confirmation in
			let expectation = Expectation(
				expectedCount: 1,
				expect: { expectation, _, _ in
					#expect(!expectation)
					confirmation()
				}
			)
			let systemUnderTest = Expectations(expectation)
			await systemUnderTest.fulfillment(within: .zero)
		}
	}

	@Test
	func test_fulfillment_triggersFalseExpectationWhenSingleExpectationOfManyTimesOut() async {
		await confirmation(expectedCount: 3) { confirmation in
			let expectation1 = Expectation(
				expectedCount: 1,
				expect: { expectation, _, _ in
					#expect(!expectation)
					confirmation()
				}
			)
			let expectation2 = Expectation(
				expectedCount: 1,
				expect: { expectation, _, _ in
					#expect(expectation)
					confirmation()
				}
			)
			expectation2.fulfill()
			let expectation3 = Expectation(
				expectedCount: 1,
				expect: { expectation, _, _ in
					#expect(expectation)
					confirmation()
				}
			)
			expectation3.fulfill()

			let systemUnderTest = Expectations(expectation1, expectation2, expectation3)
			await systemUnderTest.fulfillment(within: .zero)
		}
	}
}
