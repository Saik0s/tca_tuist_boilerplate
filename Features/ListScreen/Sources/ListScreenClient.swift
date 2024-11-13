import ComposableArchitecture
import ListScreenInterface

@DependencyClient
public struct ListScreenClient {
    public var fetchItems: () async throws -> [Item]
    public var saveItems: ([Item]) async throws -> Void
}

extension ListScreenClient: DependencyKey {
    public static let liveValue = Self(
        fetchItems: {
            // Implement actual API call here
            []
        },
        saveItems: { _ in
            // Implement actual API call here
        }
    )
}

extension DependencyValues {
    public var client: ListScreenClient {
        get { self[ListScreenClient.self] }
        set { self[ListScreenClient.self] = newValue }
    }
}
