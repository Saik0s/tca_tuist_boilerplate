import Foundation
import Dependencies

extension TaskProcessorClient: DependencyKey {
  private actor TaskQueue {
    enum TaskState {
      case notStarted, running, paused, completed, cancelled, failed
    }

    struct QueuedTask {
      let id: String
      var state: TaskState
      var progress: Double
      var task: Task<Void, Error>?
    }

    private var tasks: [String: QueuedTask] = [:]

    func add(taskId: String) async -> QueuedTask {
      let task = QueuedTask(id: taskId, state: .notStarted, progress: 0)
      tasks[taskId] = task
      return task
    }

    func update(taskId: String, state: TaskState) async {
      if var task = tasks[taskId] {
        task.state = state
        tasks[taskId] = task
      }
    }

    func update(taskId: String, progress: Double) async {
      if var task = tasks[taskId] {
        task.progress = progress
        tasks[taskId] = task
      }
    }

    func update(taskId: String, task: Task<Void, Error>) async {
      tasks[taskId]?.task = task
    }

    func get(taskId: String) async -> QueuedTask? {
      tasks[taskId]
    }

    func getState(_ taskId: String) async -> ProcessorTaskState? {
      guard let task = tasks[taskId] else { return nil }
      return switch task.state {
        case .notStarted: .notStarted
        case .running: .running
        case .paused: .paused
        case .completed: .completed
        case .cancelled: .cancelled
        case .failed: .failed(ProcessorTaskError.failed("Task failed"))
      }
    }
  }

  public static let liveValue: Self = {
    let queue = TaskQueue()
    @Dependency(\.continuousClock) var clock

    return Self(
      startTask: { input in
        AsyncStream { continuation in
          Task {
            let queuedTask = await queue.add(taskId: input.id)
            await queue.update(taskId: input.id, state: .running)

            continuation.yield(.started)
            continuation.yield(.stateChanged(.running))

            let task = Task {
              var progress: Double = 0.0
              for i in 0...10 {
                do {
                  try await clock.sleep(for: .milliseconds(500))
                  if Task.isCancelled { throw CancellationError() }
                  progress = Double(i) / 10.0
                  await queue.update(taskId: input.id, progress: progress)
                  continuation.yield(.progress(progress))
                } catch {
                  if error is CancellationError {
                    continuation.yield(.stateChanged(.cancelled))
                    continuation.finish()
                    return
                  }
                  throw error
                }
              }

              await queue.update(taskId: input.id, state: .completed)
              continuation.yield(.stateChanged(.completed))
              continuation.yield(.completed(ProcessorTaskResult(
                output: "Task \(input.id) completed",
                duration: 5.0
              )))
              continuation.finish()
            }

            await queue.update(taskId: input.id, task: task)
          }
        }
      },

      pauseTask: { taskId in
        if let task = try await queue.get(taskId: taskId) {
          await queue.update(taskId: taskId, state: .paused)
          task.task?.cancel()
        }
      },

      resumeTask: { taskId in
        await queue.update(taskId: taskId, state: .running)
      },

      cancelTask: { taskId in
        if let task = try await queue.get(taskId: taskId) {
          await queue.update(taskId: taskId, state: .cancelled)
          task.task?.cancel()
        }
      },

      observeTaskProgress: { taskId in
        AsyncStream { continuation in
          Task {
            var attempts = 0
            let maxAttempts = 100 // Prevent infinite loops
            
            while attempts < maxAttempts {
              if let task = await queue.get(taskId: taskId) {
                continuation.yield(task.progress)
                if task.state == .completed || task.state == .cancelled || task.state == .failed {
                  continuation.finish()
                  break
                }
              }
              do {
                try await clock.sleep(for: .milliseconds(500))
                attempts += 1
              } catch {
                continuation.finish()
                break
              }
            }
            continuation.finish()
          }
        }
      },

      observeTaskState: { taskId in
        AsyncStream { continuation in
          Task {
            var attempts = 0
            let maxAttempts = 100 // Prevent infinite loops
            
            while attempts < maxAttempts {
              if let state = await queue.getState(taskId) {
                continuation.yield(state)
                switch state {
                case .completed, .cancelled, .failed:
                  continuation.finish()
                  return
                default:
                  break
                }
              }
              do {
                try await clock.sleep(for: .milliseconds(500))
                attempts += 1
              } catch {
                continuation.finish()
                break
              }
            }
            continuation.finish()
          }
        }
      },

      getTaskState: { taskId in
        await queue.getState(taskId)
      }
    )
  }()
}

public extension DependencyValues {
  var taskProcessorClient: TaskProcessorClient {
    get { self[TaskProcessorClient.self] }
    set { self[TaskProcessorClient.self] = newValue }
  }
}
extension AsyncSequence {
  func timeout(_ duration: Duration) -> AsyncThrowingStream<Element, Error> {
    AsyncThrowingStream { continuation in
      Task {
        do {
          for try await element in self {
            continuation.yield(element)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }

      Task {
        try await Task.sleep(for: duration)
        continuation.finish(throwing: CancellationError())
      }
    }
  }
}
