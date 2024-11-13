//
// ListScreenClient+Live.swift
//

import ComposableArchitecture
import Foundation
import ListScreenInterface

extension ListScreenClient: @retroactive DependencyKey {
  public static let liveValue = Self(
    fetchItems: {
      try await Task.sleep(for: .seconds(1))
      return [
        ListScreenItem(
          id: UUID(),
          title: "Important Task",
          description: "Must be completed ASAP",
          createdAt: Date()
        ),
        ListScreenItem(
          id: UUID(),
          title: "Secondary Task",
          description: "Can wait until next week",
          createdAt: Date()
        ),
      ]
    },
    saveItems: { _ in
      try await Task.sleep(for: .seconds(1))
      // In a real implementation, this would persist the items
    }
  )
}

extension DependencyValues {
  public var listScreenClient: ListScreenClient {
    get { self[ListScreenClient.self] }
    set { self[ListScreenClient.self] = newValue }
  }
}
