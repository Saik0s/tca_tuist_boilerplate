//
// ListScreenTesting.swift
//

import Foundation
import IdentifiedCollections
import ListScreenInterface

public extension ListScreenItem {
  static let mock = ListScreenItem(
    id: UUID(0),
    title: "Mock Item",
    description: "Mock Description",
    createdAt: Date(timeIntervalSince1970: 0)
  )

  static let mocks: IdentifiedArrayOf<ListScreenItem> = [
    ListScreenItem(
      id: UUID(0),
      title: "First Item",
      description: "First Description",
      createdAt: Date(timeIntervalSince1970: 0)
    ),
    ListScreenItem(
      id: UUID(1),
      title: "Second Item",
      description: "Second Description",
      createdAt: Date(timeIntervalSince1970: 1)
    ),
    ListScreenItem(
      id: UUID(2),
      title: "Third Item",
      description: "Third Description",
      createdAt: Date(timeIntervalSince1970: 2)
    ),
  ]
}

public extension ListScreenClient {
  static let previewValue = Self(
    fetchItems: { ListScreenItem.mocks },
    saveItems: { _ in }
  )
}
