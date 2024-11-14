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
      for await event in client.startTask(input) {
        receivedEvents.append(event)
      }
    }

    for _ in 0..<10 {
      await clock.advance(by: .milliseconds(500))
    }
    await clock.advance(by: .milliseconds(500))

    await eventsTask.value

    XCTAssertEqual(receivedEvents.count, 12)
    XCTAssertEqual(receivedEvents.first, .started)

    let progressEvents = receivedEvents.dropFirst().dropLast()
    for (index, event) in progressEvents.enumerated() {
      if case let .progress(value) = event {
        XCTAssertEqual(value, Double(index + 1) * 0.1, accuracy: 0.001)
      }
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
      for await event in client.startTask(input) {
        if case .started = event {
          started = true
          break
        }
      }
      XCTAssertTrue(started)
    }

    await clock.advance(by: .milliseconds(500))
    await streamTask.value

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
      for await event in client.startTask(input) {
        if case .started = event {
          started = true
          break
        }
      }
      XCTAssertTrue(started)
    }

    await clock.advance(by: .milliseconds(500))
    await streamTask.value

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
      for await progress in client.observeTaskProgress(taskId) {
        progressValues.append(progress)
        if progress >= 1.0 { break }
      }
    }

    // Advance clock for both tasks
    for _ in 0..<10 {
      await clock.advance(by: .milliseconds(500))
    }

    await streamTask.value
    await progressTask.value

    XCTAssertGreaterThan(progressValues.count, 0)
    XCTAssertEqual(progressValues.last!, 1.0, accuracy: 0.001)

    for i in 1..<progressValues.count {
      XCTAssertGreaterThan(progressValues[i], progressValues[i-1])
    }
  }
}
