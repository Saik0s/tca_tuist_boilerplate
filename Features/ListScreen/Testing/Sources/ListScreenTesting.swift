import XCTest
import ComposableArchitecture
@testable import ListScreen
import ListScreenInterface

public enum ListScreenTesting {
    public static func mockItem(id: UUID = UUID()) -> Item {
        Item(id: id, title: "Mock Item", description: "Mock Description", createdAt: Date())
    }

    public static let mockClient = ListScreenClient(
        fetchItems: { [mockItem()] },
        saveItems: { _ in }
    )
}

extension ListScreenClient {
    public static let test = Self(
        fetchItems: unimplemented("ListScreenClient.fetchItems"),
        saveItems: unimplemented("ListScreenClient.saveItems")
    )
}
