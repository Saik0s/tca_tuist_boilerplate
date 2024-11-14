import Foundation
import Dependencies

extension TaskProcessorClient: DependencyKey {
  private actor TaskQueue {
    enum TaskState {
      case notStarted, running, paused, completed, cancelled
    }

    struct QueuedTask {
      let id: String
      var state: TaskState
      var progress: Double
      var task: Task<Void, Error>?
    }

    private var tasks: [String: QueuedTask] = [:]

    func add(taskId: String) -> QueuedTask {
      let task = QueuedTask(id: taskId, state: .notStarted, progress: 0)
      tasks[taskId] = task
      return task
    }

    func update(taskId: String, state: TaskState) {
      if var task = tasks[taskId] {
        task.state = state
        tasks[taskId] = task
      }
    }

    func update(taskId: String, progress: Double) {
      tasks[taskId]?.progress = progress
    }

    func update(taskId: String, task: Task<Void, Error>) {
      tasks[taskId]?.task = task
    }

    func get(taskId: String) -> QueuedTask? {
      tasks[taskId]
    }

    func getState(_ taskId: String) -> ProcessorTaskState? {
      guard let task = tasks[taskId] else { return nil }
      return switch task.state {
        case .notStarted: .notStarted
        case .running: .running
        case .paused: .paused
        case .completed: .completed
        case .cancelled: .cancelled
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
              var progress: Double = 0
              while progress <= 0.9 {
                do {
                  try await clock.sleep(for: .milliseconds(500))
                  if Task.isCancelled { throw CancellationError() }
                  progress = min(1.0, progress + 0.1)
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
        if let task = await queue.get(taskId: taskId) {
          await queue.update(taskId: taskId, state: .paused)
          task.task?.cancel()
        }
      },

      resumeTask: { taskId in
        await queue.update(taskId: taskId, state: .running)
      },

      cancelTask: { taskId in
        if let task = await queue.get(taskId: taskId) {
          await queue.update(taskId: taskId, state: .cancelled)
          task.task?.cancel()
        }
      },

      observeTaskProgress: { taskId in
        AsyncStream { continuation in
          Task {
            while true {
              if let task = await queue.get(taskId: taskId) {
                continuation.yield(task.progress)
                if task.state == .completed || task.state == .cancelled || task.state == .paused || task.state == .failed {
                  continuation.finish()
                  break
                }
              }
              do {
                try await clock.sleep(for: .milliseconds(500))
              } catch {
                continuation.finish()
                break
              }
            }
          }
        }
      },

      observeTaskState: { taskId in
        AsyncStream { continuation in
          Task {
            while true {
              if let state = await queue.getState(taskId) {
                continuation.yield(state)
                switch state {
                case .completed, .cancelled, .paused, .failed:
                  continuation.finish()
                  break
                default:
                  break
                }
              }
              do {
                try await clock.sleep(for: .milliseconds(500))
              } catch {
                continuation.finish()
                break
              }
            }
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
