//
// TaskProcessorTests.swift
//

import Dependencies
@testable import TaskProcessor
import TaskProcessorInterface
import XCTest

final class TaskProcessorTests: XCTestCase {
  @MainActor
  func testBasicTaskFlow() async throws {
    let taskId = "test-task-1"
    let input = ProcessorTaskInput(id: taskId)
    let events = LockIsolated<[ProcessorTaskEvent]>([])

    let client = withDependencies {
      $0.taskProcessorOperation = { input, progress in
        // Ensure deterministic progress updates
        for i in 0 ... 10 {
          try Task.checkCancellation()
          progress(Double(i) / 10.0)
          // Add small delay to allow events to be processed
          try await Task.sleep(for: .milliseconds(10))
        }
        return ProcessorTaskResult(
          output: "Task \(input.id) completed",
          duration: 5.0
        )
      }
    } operation: {
      TaskProcessorClient.liveValue
    }

    let eventsTask = Task {
      for try await event in try await client.observeTaskState(taskId) {
        events.withValue { $0.append(.stateChanged(event)) }
        if event == .completed {
          break
        }
      }
    }

    try await client.addTaskToQueue(input)
    try await eventsTask.value

    // Assert events arrived in correct order
    let receivedEvents = events.value
    XCTAssertEqual(receivedEvents.count, 3)
    XCTAssertEqual(receivedEvents[0], .stateChanged(.notStarted))
    XCTAssertEqual(receivedEvents[1], .stateChanged(.running))
    XCTAssertEqual(receivedEvents[2], .stateChanged(.completed))
  }

  @MainActor
  func testTaskCancellation() async throws {
    let taskId = "test-task-1"

    let client = withDependencies {
      $0.taskProcessorOperation = { _, _ in
        ProcessorTaskResult(output: "Cancelled", duration: 1.0)
      }
    } operation: {
      TaskProcessorClient.liveValue
    }

    let input = ProcessorTaskInput(id: taskId)
    try await client.addTaskToQueue(input)
    try await client.cancelTask(taskId)

    let state = try await client.getTaskState(taskId)
    XCTAssertEqual(state, .cancelled)
  }

  @MainActor
  func testTaskPauseResume() async throws {
    let taskId = "test-task-1"

    let client = withDependencies {
      $0.taskProcessorOperation = { _, _ in
        ProcessorTaskResult(output: "Complete", duration: 1.0)
      }
    } operation: {
      TaskProcessorClient.liveValue
    }

    let input = ProcessorTaskInput(id: taskId)
    try await client.addTaskToQueue(input)
    try await client.pauseTask(taskId)

    var state = try await client.getTaskState(taskId)
    XCTAssertEqual(state, .paused)

    try await client.resumeTask(taskId)
    state = try await client.getTaskState(taskId)
    XCTAssertEqual(state, .running)
  }

  @MainActor
  func testProgressObservation() async throws {
    let taskId = "test-task-1"

    let client = withDependencies {
      $0.taskProcessorOperation = { _, progress in
        for i in 0 ... 10 {
          progress(Double(i) / 10.0)
        }
        return ProcessorTaskResult(output: "Complete", duration: 1.0)
      }
    } operation: {
      TaskProcessorClient.liveValue
    }

    let input = ProcessorTaskInput(id: taskId)
    var progressValues: [Double] = []

    let progressTask = Task {
      for try await progress in try await client.observeTaskProgress(taskId) {
        progressValues.append(progress)
        if progress >= 1.0 { break }
      }
    }

    try await client.addTaskToQueue(input)
    try await progressTask.value

    XCTAssertGreaterThan(progressValues.count, 0)
    XCTAssertEqual(progressValues.last!, 1.0, accuracy: 0.001)

    for i in 1 ..< progressValues.count {
      XCTAssertGreaterThanOrEqual(progressValues[i], progressValues[i - 1])
    }
  }
}
