import XCTest
import Dependencies
@testable import TaskProcessor

final class TaskProcessorTests: XCTestCase {
  @MainActor
  func testBasicTaskFlow() async throws {
    let clock = TestClock()
    let taskId = "test-task-1"
    let input = ProcessorTaskInput(id: taskId)
    var receivedEvents: [ProcessorTaskEvent] = []

    let client = withDependencies {
      $0.continuousClock = clock
    } operation: {
      TaskProcessorClient.liveValue
    }

    let eventsTask = Task {
      for try await event in client.startTask(input).timeout(.seconds(5)) {
        receivedEvents.append(event)
      }
    }

    // Start a timeout task
    let timeoutTask = Task {
        try await Task.sleep(for: .seconds(5))
        eventsTask.cancel()
    }

    for _ in 0..<10 {
      await clock.advance(by: .milliseconds(500))
    }
    await clock.advance(by: .milliseconds(500))

    try await eventsTask.value
    timeoutTask.cancel()

    XCTAssertEqual(receivedEvents.count, 15) // started + stateChanges + 11 progress + completed
    XCTAssertEqual(receivedEvents.first, .started)

    // Extract only the progress events
    let progressEvents = receivedEvents.compactMap { event -> Double? in
        if case let .progress(value) = event { return value } else { return nil }
    }
    
    // Assert the count of progress events
    XCTAssertEqual(progressEvents.count, 11)
    
    // Check each progress value
    for (index, value) in progressEvents.enumerated() {
        let expected = Double(index) / 10.0
        XCTAssertEqual(value, expected, accuracy: 0.001)
    }

    if case let .completed(result) = receivedEvents.last {
      XCTAssertEqual(result.output, "Task \(taskId) completed")
      XCTAssertEqual(result.duration, 5.0)
    } else {
      XCTFail("Last event should be .completed")
    }
  }

  @MainActor
  func testTaskCancellation() async throws {
    let clock = TestClock()
    let taskId = "test-task-1"

    let client = withDependencies {
      $0.continuousClock = clock
    } operation: {
      TaskProcessorClient.liveValue
    }

    let input = ProcessorTaskInput(id: taskId)
    let streamTask = Task {
      var started = false
      for try await event in client.startTask(input) {
        if case .started = event {
          started = true
          break
        }
      }
      XCTAssertTrue(started)
    }

    let timeoutTask = Task {
      try await Task.sleep(nanoseconds: 5_000_000_000)
      streamTask.cancel()
    }

    await clock.advance(by: .milliseconds(500))
    try await streamTask.value
    timeoutTask.cancel()

    try await client.cancelTask(taskId)
    let state = await client.getTaskState(taskId)
    XCTAssertEqual(state, .cancelled)
  }

  @MainActor
  func testTaskPauseResume() async throws {
    let clock = TestClock()
    let taskId = "test-task-1"

    let client = withDependencies {
      $0.continuousClock = clock
    } operation: {
      TaskProcessorClient.liveValue
    }

    let input = ProcessorTaskInput(id: taskId)
    let streamTask = Task {
      var started = false
      for try await event in client.startTask(input) {
        if case .started = event {
          started = true
          break
        }
      }
      XCTAssertTrue(started)
    }

    await clock.advance(by: .milliseconds(500))
    try await streamTask.value

    try await client.pauseTask(taskId)
    var state = await client.getTaskState(taskId)
    XCTAssertEqual(state, .paused)

    try await client.resumeTask(taskId)
    state = await client.getTaskState(taskId)
    XCTAssertEqual(state, .running)
  }

  @MainActor
  func testProgressObservation() async throws {
    let clock = TestClock()
    let taskId = "test-task-1"

    let client = withDependencies {
      $0.continuousClock = clock
    } operation: {
      TaskProcessorClient.liveValue
    }

    var progressValues: [Double] = []

    let input = ProcessorTaskInput(id: taskId)
    let streamTask = Task {
      _ = client.startTask(input)
    }

    let progressTask = Task {
      for try await progress in client.observeTaskProgress(taskId).timeout(.seconds(5)) {
        progressValues.append(progress)
        if progress >= 1.0 { break }
      }
    }

    // Advance clock for both tasks
    for _ in 0..<10 {
      await clock.advance(by: .milliseconds(500))
    }

    try await streamTask.value
    await progressTask.value

    XCTAssertGreaterThan(progressValues.count, 0)
    XCTAssertEqual(progressValues.last!, 1.0, accuracy: 0.001)

    for i in 1..<progressValues.count {
      XCTAssertGreaterThan(progressValues[i], progressValues[i-1])
    }
  }
}
