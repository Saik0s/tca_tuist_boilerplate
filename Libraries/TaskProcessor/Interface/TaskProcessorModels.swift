//
// TaskProcessorModels.swift
//

import CasePaths
import Foundation

// MARK: - ProcessorTaskInput

public struct ProcessorTaskInput: Equatable {
  public let id: String
  public let parameters: [String: AnyHashable]

  public init(id: String, parameters: [String: AnyHashable] = [:]) {
    self.id = id
    self.parameters = parameters
  }
}

// MARK: - ProcessorTaskState

public enum ProcessorTaskState: Equatable, Sendable {
  case notStarted
  case running
  case paused
  case completed
  case cancelled
  case failed(ProcessorTaskError)
}

// MARK: - ProcessorTaskEvent

@CasePathable
public enum ProcessorTaskEvent: Equatable {
  case started
  case progress(Double)
  case completed(ProcessorTaskResult)
  case failed(ProcessorTaskError)
  case stateChanged(ProcessorTaskState)

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.started, .started): true
    case let (.progress(l), .progress(r)): l == r
    case let (.completed(l), .completed(r)): l == r
    case let (.failed(l), .failed(r)): l == r
    case let (.stateChanged(l), .stateChanged(r)): l == r
    default: false
    }
  }
}

// MARK: - ProcessorTaskResult

public struct ProcessorTaskResult: Equatable {
  public let output: String
  public let duration: TimeInterval

  public init(output: String, duration: TimeInterval) {
    self.output = output
    self.duration = duration
  }
}

// MARK: - ProcessorTaskError

public enum ProcessorTaskError: Error, Equatable {
  case cancelled
  case failed(String)
  case error(Error)

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.cancelled, .cancelled):
      true

    case let (.failed(l), .failed(r)):
      l == r

    case let (.error(l), .error(r)):
      "\(l)" == "\(r)"
    default:
      false
    }
  }
}
