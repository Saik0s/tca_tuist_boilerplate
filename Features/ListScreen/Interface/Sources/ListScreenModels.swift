//
// ListScreenModels.swift
//

import Foundation
import IdentifiedCollections

// MARK: - ListScreenItem

public struct ListScreenItem: Equatable, Identifiable, Codable {
  public let id: UUID
  public var title: String
  public var description: String
  public let createdAt: Date

  public init(id: UUID, title: String, description: String, createdAt: Date) {
    self.id = id
    self.title = title
    self.description = description
    self.createdAt = createdAt
  }
}

// MARK: - ListScreenSortOrder

public enum ListScreenSortOrder: Equatable, CaseIterable {
  case alphabetical, date, custom
}

// MARK: - ListScreenFilterCriteria

public struct ListScreenFilterCriteria: Equatable {
  public var searchText: String

  public init(searchText: String) {
    self.searchText = searchText
  }
}
