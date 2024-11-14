//
// LiveTaskProcessorClient.swift
//

import Dependencies
import Foundation
import TaskProcessorInterface

// MARK: - TaskProcessorClient + DependencyKey

extension TaskProcessorClient: @retroactive DependencyKey {
  public static let liveValue: Self = {
    @Dependency(\.taskProcessorOperation) var taskProcessorOperation
    let taskManager = TaskManager(taskProcessorOperation: taskProcessorOperation)

    return Self(
      addTaskToQueue: { input in
        Task {
          await taskManager.addTaskToQueue(input)
        }
      },
      observeQueue: {
        await taskManager.observeQueue()
      },
      observeTaskProgress: { taskId in
        await taskManager.observeTaskProgress(taskId: taskId)
      },
      observeTaskState: { taskId in
        await taskManager.observeTaskState(taskId: taskId)
      },
      pauseTask: { taskId in
        await taskManager.pauseTask(taskId: taskId)
      },
      resumeTask: { taskId in
        await taskManager.resumeTask(taskId: taskId)
      },
      cancelTask: { taskId in
        await taskManager.cancelTask(taskId: taskId)
      },
      getTaskState: { taskId in
        await taskManager.getTaskState(taskId: taskId)
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
