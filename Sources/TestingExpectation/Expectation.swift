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

public actor Expectation {
	// MARK: Initialization

	/// An expected outcome in an asynchronous test.
	/// - Parameters:
	///   - expectedCount: The number of times `fulfill()` must be called before the expectation is completely fulfilled.
	///   - conditionFulfillmentAwaited: When `true`, crashes in `deinit` when an expectation is created but its fulfillment has not been awaited.
	public init(
		expectedCount: UInt = 1,
		conditionFulfillmentAwaited: Bool = true,
		filePath: String = #filePath,
		fileID: String = #fileID,
		line: Int = #line,
		column: Int = #column
	) {
		self.init(
			expectedCount: expectedCount,
			expect: { fulfilledWithExpectedCount, comment, sourceLocation in
				#expect(fulfilledWithExpectedCount, comment, sourceLocation: sourceLocation)
			},
			precondition: conditionFulfillmentAwaited ? Swift.precondition : nil,
			filePath: filePath,
			fileID: fileID,
			line: line,
			column: column
		)
	}

	init(
		expectedCount: UInt,
		expect: @escaping @Sendable (Bool, Comment?, SourceLocation) -> Void,
		precondition: (@Sendable (@autoclosure () -> Bool, @autoclosure () -> String, StaticString, UInt) -> Void)? = nil,
		filePath: String = #filePath,
		fileID: String = #fileID,
		line: Int = #line,
		column: Int = #column
	) {
		self.expectedCount = expectedCount
		self.expect = expect
		self.precondition = precondition
		createdSourceLocation = .init(
			fileID: fileID,
			filePath: filePath,
			line: line,
			column: column
		)
	}

	deinit {
		let fulfillmentAwaited = fulfillmentAwaited
		if let precondition {
			precondition(fulfillmentAwaited, "Expectation created at \(createdSourceLocation) was never awaited", #file, #line)
		}
	}

	// MARK: Public

	public func fulfillment(
		within duration: Duration,
		filePath: String = #filePath,
		fileID: String = #fileID,
		line: Int = #line,
		column: Int = #column
	) async {
		fulfillmentAwaited = true
		guard !isComplete else { return }
		let wait = Task {
			try await Task.sleep(for: duration)
			expect(isComplete, "Expectation not fulfilled within \(duration)", .init(
				fileID: fileID,
				filePath: filePath,
				line: line,
				column: column
			))
		}
		waits.append(wait)
		try? await wait.value
	}

	@discardableResult
	nonisolated
	public func fulfill(
		filePath: String = #filePath,
		fileID: String = #fileID,
		line: Int = #line,
		column: Int = #column
	) -> Task<Void, Never> {
		Task {
			await self._fulfill(
				filePath: filePath,
				fileID: fileID,
				line: line,
				column: column
			)
		}
	}

	// MARK: Private

	private var waits = [Task<Void, Error>]()
	private var fulfillCount: UInt = 0
	private var isComplete: Bool {
		expectedCount <= fulfillCount
	}

	private var fulfillmentAwaited = false

	private let expectedCount: UInt
	private let expect: @Sendable (Bool, Comment?, SourceLocation) -> Void
	private let precondition: (@Sendable (@autoclosure () -> Bool, @autoclosure () -> String, StaticString, UInt) -> Void)?
	private let createdSourceLocation: SourceLocation

	private func _fulfill(
		filePath: String,
		fileID: String,
		line: Int,
		column: Int
	) {
		fulfillCount += 1
		guard isComplete else { return }
		expect(
			expectedCount == fulfillCount,
			"Expected \(expectedCount) calls to `fulfill()`. Received \(fulfillCount).",
			.init(
				fileID: fileID,
				filePath: filePath,
				line: line,
				column: column
			)
		)
		for wait in waits {
			wait.cancel()
		}
		waits = []
	}
}
