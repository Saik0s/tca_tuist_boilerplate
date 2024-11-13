//
// ListScreenClient.swift
//

import Dependencies
import DependenciesMacros
import IdentifiedCollections

// MARK: - ListScreenClient

@DependencyClient
public struct ListScreenClient {
  public var fetchItems: () async throws -> IdentifiedArrayOf<ListScreenItem>
  public var saveItems: ([ListScreenItem]) async throws -> Void
}

// MARK: TestDependencyKey

extension ListScreenClient: TestDependencyKey {
  public static let testValue = Self()
}

public extension DependencyValues {
  var listScreenClient: ListScreenClient {
    get { self[ListScreenClient.self] }
    set { self[ListScreenClient.self] = newValue }
  }
}
