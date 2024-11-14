//
// TaskProcessorClient.swift
//

import Dependencies
import DependenciesMacros
import Foundation

// MARK: - TaskProcessorClient

@DependencyClient
public struct TaskProcessorClient {
  public var addTaskToQueue: @Sendable (_ input: ProcessorTaskInput) async throws -> Void
  public var observeQueue: @Sendable () async throws -> AsyncStream<[String]>
  public var observeTaskProgress: @Sendable (_ id: String) async throws -> AsyncStream<Double>
  public var observeTaskState: @Sendable (_ id: String) async throws -> AsyncStream<ProcessorTaskState>
  public var pauseTask: @Sendable (_ id: String) async throws -> Void
  public var resumeTask: @Sendable (_ id: String) async throws -> Void
  public var cancelTask: @Sendable (_ id: String) async throws -> Void
  public var getTaskState: @Sendable (_ id: String) async throws -> ProcessorTaskState?
}

// MARK: TestDependencyKey

extension TaskProcessorClient: TestDependencyKey {
  public static let testValue = Self()
}
