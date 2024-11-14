//
// TaskProcessorOperation.swift
//

import Dependencies
import DependenciesMacros
import Foundation

public typealias TaskProcessorOperation = @Sendable (ProcessorTaskInput, @escaping (_ progress: Double) -> Void) async throws -> ProcessorTaskResult

// MARK: - TaskProcessorOperationKey

public enum TaskProcessorOperationKey: TestDependencyKey {
  public static let testValue: TaskProcessorOperation = { _, _ in throw ProcessorTaskError.failed("Implementation not provided") }
}

public extension DependencyValues {
  var taskProcessorOperation: TaskProcessorOperation {
    get { self[TaskProcessorOperationKey.self] }
    set { self[TaskProcessorOperationKey.self] = newValue }
  }
}
