import Foundation
import IdentifiedCollections

public struct Item: Equatable, Identifiable, Codable, Sendable {
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

public enum ListSortOrder: Equatable, CaseIterable, Sendable {
    case alphabetical, date, custom
}

public struct FilterCriteria: Equatable, Sendable {
    public var searchText: String

    public init(searchText: String) {
        self.searchText = searchText
    }
}
