import XCTest
import ComposableArchitecture
import SnapshotTesting
@testable import ListScreen
import ListScreenTesting

@MainActor
final class ListScreenTests: XCTestCase {
    func testInitialState() async {
        let store = TestStore(initialState: ListScreenFeature.State()) {
            ListScreenFeature()
        } withDependencies: {
            $0.client = .test
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
    }

    func testLoadItems_Success() async {
        let mockItems = [
            ListScreenTesting.mockItem(id: UUID(0)),
            ListScreenTesting.mockItem(id: UUID(1))
        ]

        let store = TestStore(initialState: ListScreenFeature.State()) {
            ListScreenFeature()
        } withDependencies: {
            $0.client.fetchItems = { mockItems }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.itemsResponse.success) {
            $0.isLoading = false
            $0.items = IdentifiedArray(uniqueElements: mockItems)
        }
    }

    func testLoadItems_Failure() async {
        let store = TestStore(initialState: ListScreenFeature.State()) {
            ListScreenFeature()
        } withDependencies: {
            $0.client.fetchItems = {
                struct FetchError: Error {}
                throw FetchError()
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.itemsResponse.failure) {
            $0.isLoading = false
            $0.destination = .alert(
                AlertState(title: TextState("Error"), message: TextState("Failed to load items"))
            )
        }
    }

    func testAddItem() async {
        let store = TestStore(initialState: ListScreenFeature.State()) {
            ListScreenFeature()
        } withDependencies: {
            $0.client = .test
            $0.client.saveItems = { _ in }
        }

        await store.send(.addButtonTapped) {
            $0.destination = .add(AddItem.State())
        }

        let newItem = store.state.destination?.add?.item
        await store.send(.destination(.presented(.add(.saveButtonTapped(newItem!))))) {
            $0.destination = nil
            $0.items = [newItem!]
        }
    }

    func testEditItem() async {
        let item = ListScreenTesting.mockItem()
        let store = TestStore(
            initialState: ListScreenFeature.State(items: [item])
        ) {
            ListScreenFeature()
        } withDependencies: {
            $0.client = .test
            $0.client.saveItems = { _ in }
        }

        await store.send(.itemTapped(item.id)) {
            $0.destination = .edit(EditItem.State(item: item))
        }

        var editedItem = item
        editedItem.title = "Updated Title"

        await store.send(.destination(.presented(.edit(.setTitle("Updated Title"))))) {
            $0.destination?.edit?.item.title = "Updated Title"
        }

        await store.send(.destination(.presented(.edit(.saveButtonTapped(editedItem))))) {
            $0.destination = nil
            $0.items[id: item.id]?.title = "Updated Title"
        }
    }

    func testDeleteItem() async {
        let item = ListScreenTesting.mockItem()
        let store = TestStore(
            initialState: ListScreenFeature.State(items: [item])
        ) {
            ListScreenFeature()
        } withDependencies: {
            $0.client = .test
            $0.client.saveItems = { _ in }
        }

        await store.send(.deleteItem([0])) {
            $0.destination = .alert(
                AlertState { TextState("Delete Item") }
                actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion(item.id)) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                }
                message: {
                    TextState("Are you sure you want to delete this item?")
                }
            )
        }

        await store.send(.destination(.presented(.alert(.confirmDeletion(item.id))))) {
            $0.destination = nil
            $0.items = []
        }
    }

    func testSortItems() async {
        let items = [
            Item(id: UUID(0), title: "B Item", description: "", createdAt: Date(timeIntervalSince1970: 2)),
            Item(id: UUID(1), title: "A Item", description: "", createdAt: Date(timeIntervalSince1970: 1))
        ]

        let store = TestStore(
            initialState: ListScreenFeature.State(items: items)
        ) {
            ListScreenFeature()
        } withDependencies: {
            $0.client = .test
        }

        await store.send(.setSortOrder(.alphabetical)) {
            $0.sortOrder = .alphabetical
            $0.items.sort { $0.title < $1.title }
        }

        await store.send(.setSortOrder(.date)) {
            $0.sortOrder = .date
            $0.items.sort { $0.createdAt < $1.createdAt }
        }
    }
}

// MARK: - Snapshot Tests
extension ListScreenTests {
    func testViewSnapshots() {
        let items = [
            Item(
                id: UUID(0),
                title: "Test Item 1",
                description: "Description 1",
                createdAt: Date(timeIntervalSince1970: 0)
            ),
            Item(
                id: UUID(1),
                title: "Test Item 2",
                description: "Description 2",
                createdAt: Date(timeIntervalSince1970: 1)
            )
        ]

        let store = Store(
            initialState: ListScreenFeature.State(items: items)
        ) {
            ListScreenFeature()
        } withDependencies: {
            $0.client = .test
        }

        let view = ListScreenView(store: store)

        assertSnapshot(
            matching: view,
            as: .image(layout: .device(config: .iPhone13Pro))
        )

        // Test empty state
        let emptyStore = Store(
            initialState: ListScreenFeature.State()
        ) {
            ListScreenFeature()
        }

        let emptyView = ListScreenView(store: emptyStore)
        assertSnapshot(
            matching: emptyView,
            as: .image(layout: .device(config: .iPhone13Pro)),
            named: "empty"
        )

        // Test loading state
        let loadingStore = Store(
            initialState: ListScreenFeature.State(isLoading: true)
        ) {
            ListScreenFeature()
        }

        let loadingView = ListScreenView(store: loadingStore)
        assertSnapshot(
            matching: loadingView,
            as: .image(layout: .device(config: .iPhone13Pro)),
            named: "loading"
        )
    }
}
