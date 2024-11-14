//
// TaskProcessorClient.swift
//

import Dependencies
import DependenciesMacros
import Foundation

// MARK: - TaskProcessorClient

@DependencyClient
public struct TaskProcessorClient {
  public var startTask: @Sendable (ProcessorTaskInput) -> AsyncStream<ProcessorTaskEvent> = { _ in
    AsyncStream { _ in }
  }

  public var pauseTask: @Sendable (String) async throws -> Void
  public var resumeTask: @Sendable (String) async throws -> Void
  public var cancelTask: @Sendable (String) async throws -> Void

  public var observeTaskProgress: @Sendable (String) -> AsyncStream<Double> = { _ in
    AsyncStream { _ in }
  }

  public var observeTaskState: @Sendable (String) -> AsyncStream<ProcessorTaskState> = { _ in
    AsyncStream { _ in }
  }

  public var getTaskState: @Sendable (String) async -> ProcessorTaskState? = { _ in nil }
}

// MARK: TestDependencyKey

extension TaskProcessorClient: TestDependencyKey {
  public static let testValue = Self()
}
