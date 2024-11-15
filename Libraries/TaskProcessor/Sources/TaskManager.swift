//
// TaskManager.swift
//

import Foundation
import TaskProcessorInterface

// MARK: - TaskManager

actor TaskManager {
  // MARK: - Types

  struct QueuedTask {
    let input: ProcessorTaskInput
    var state: ProcessorTaskState = .notStarted
    var isPaused = false
    var progress: Double = 0.0
  }

  struct ProcessorTaskResult {
    let success: Bool
    let error: Error?
  }

  // MARK: - Properties

  private var taskQueue: [ProcessorTaskInput] = []
  private var isProcessing = false
  private var tasks: [String: QueuedTask] = [:]

  /// Continuations for observations
  private var queueContinuation: AsyncStream<[String]>.Continuation?
  private var progressContinuations: [String: AsyncStream<Double>.Continuation] = [:]
  private var stateContinuations: [String: AsyncStream<ProcessorTaskState>.Continuation] = [:]

  private let taskProcessorOperation: TaskProcessorOperation

  // MARK: - Initialization

  init(taskProcessorOperation: @escaping TaskProcessorOperation) {
    self.taskProcessorOperation = taskProcessorOperation
  }

  // MARK: - Public Methods

  func addTaskToQueue(_ input: ProcessorTaskInput) {
    taskQueue.append(input)
    tasks[input.id] = QueuedTask(input: input)
    stateContinuations[input.id]?.yield(.notStarted)
    queueContinuation?.yield(taskQueue.map(\.id))

    if !isProcessing {
      Task {
        await processNextTask()
      }
    }
  }

  func observeQueue() -> AsyncStream<[String]> {
    AsyncStream { continuation in
      queueContinuation = continuation
      continuation.yield(taskQueue.map(\.id))
    }
  }

  func observeTaskProgress(taskId: String) -> AsyncStream<Double> {
    AsyncStream { continuation in
      progressContinuations[taskId] = continuation
      if let progress = tasks[taskId]?.progress {
        continuation.yield(progress)
      }
    }
  }

  func observeTaskState(taskId: String) -> AsyncStream<ProcessorTaskState> {
    AsyncStream { continuation in
      stateContinuations[taskId] = continuation
      if let state = tasks[taskId]?.state {
        continuation.yield(state)
      }
    }
  }

  func getTaskState(taskId: String) -> ProcessorTaskState? {
    tasks[taskId]?.state
  }

  func pauseTask(taskId: String) {
    if var task = tasks[taskId] {
      if task.state == .running || task.state == .notStarted {
        task.isPaused = true
        task.state = .paused
        tasks[taskId] = task
        stateContinuations[taskId]?.yield(.paused)
      }
    }
  }

  func resumeTask(taskId: String) {
    if var task = tasks[taskId], task.state == .paused {
      task.isPaused = false
      task.state = .running
      tasks[taskId] = task
      stateContinuations[taskId]?.yield(.running)
    }
  }

  func cancelTask(taskId: String) {
    if var task = tasks[taskId], task.state != .completed && task.state != .cancelled {
      task.state = .cancelled
      tasks[taskId] = task
      stateContinuations[taskId]?.yield(.cancelled)
      progressContinuations[taskId]?.finish()
      stateContinuations[taskId]?.finish()
    }
  }

  // MARK: - Private Methods

  private func processTask(_ input: ProcessorTaskInput) async {
    guard var task = tasks[input.id] else { return }

    if !task.isPaused {
      task.state = .running
      tasks[input.id] = task
      stateContinuations[input.id]?.yield(.running)
    }

    do {
      let manager = self
      let result = try await taskProcessorOperation(input) { progress in
        Task { @MainActor in
          await manager.updateProgress(taskId: input.id, progress: progress)
        }
      }

      task.state = .completed
      tasks[input.id] = task
      stateContinuations[input.id]?.yield(task.state)
    } catch {
      task.state = .failed(.error(error))
      tasks[input.id] = task
      stateContinuations[input.id]?.yield(.failed(.error(error)))
    }

    progressContinuations[input.id]?.finish()
    stateContinuations[input.id]?.finish()
  }

  private func updateProgress(taskId: String, progress: Double) {
    tasks[taskId]?.progress = progress
    progressContinuations[taskId]?.yield(progress)
  }

  private func processNextTask() async {
    guard !taskQueue.isEmpty else {
      isProcessing = false
      return
    }
    isProcessing = true
    let input = taskQueue.removeFirst()
    queueContinuation?.yield(taskQueue.map(\.id))

    await processTask(input)
    await processNextTask()
  }
}
