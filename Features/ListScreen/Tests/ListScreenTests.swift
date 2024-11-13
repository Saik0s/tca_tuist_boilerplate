//
// ListScreenTests.swift
//

import ComposableArchitecture
import Foundation
@testable import ListScreen
import ListScreenInterface
import ListScreenTesting
import Testing

@MainActor
struct ListScreenTests {
  @Test
  func testInitialState() async {
    let store = TestStore(initialState: ListScreenFeature.State()) {
      ListScreenFeature()
    } withDependencies: {
      $0.listScreenClient.fetchItems = { ListScreenItem.mocks }
    }
    store.exhaustivity = .off

    await store.send(.onAppear) {
      $0.isLoading = true
    }
  }

  @Test
  func testLoadItems_Success() async {
    let store = TestStore(initialState: ListScreenFeature.State()) {
      ListScreenFeature()
    } withDependencies: {
      $0.listScreenClient.fetchItems = { ListScreenItem.mocks }
    }

    await store.send(.onAppear) {
      $0.isLoading = true
    }

    await store.receive(\.itemsResponse.success) {
      $0.isLoading = false
      $0.items = ListScreenItem.mocks
    }
  }

  @Test
  func testLoadItems_Failure() async {
    let store = TestStore(initialState: ListScreenFeature.State()) {
      ListScreenFeature()
    } withDependencies: {
      $0.listScreenClient.fetchItems = {
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
        AlertState(
          title: { TextState("Error") },
          actions: { ButtonState(role: .cancel) { TextState("OK") } },
          message: { TextState("Failed to load items") }
        )
      )
    }
  }

  @Test
  func testAddItem() async {
    let date = Date(timeIntervalSince1970: 0)

    let store = TestStore(initialState: ListScreenFeature.State()) {
      ListScreenFeature()
    } withDependencies: {
      $0.listScreenClient.saveItems = { _ in }
      $0.uuid = .incrementing
      $0.date = .constant(date)
    }

    let item = ListScreenItem(id: UUID(0), title: "New Item", description: "", createdAt: date)
    await store.send(.addButtonTapped) {
      $0.destination = .add(ListScreenAddItem.State(item: item))
    }

    await store.send(.destination(.presented(.add(.saveButtonTapped(item))))) {
      $0.destination = nil
      $0.items = [item]
    }
  }

  @Test
  func testAddItem_Cancel() async {
    let date = Date(timeIntervalSince1970: 0)

    let store = TestStore(initialState: ListScreenFeature.State()) {
      ListScreenFeature()
    } withDependencies: {
      $0.uuid = .incrementing
      $0.date = .constant(date)
    }

    let item = ListScreenItem(id: UUID(0), title: "New Item", description: "", createdAt: date)
    await store.send(.addButtonTapped) {
      $0.destination = .add(ListScreenAddItem.State(item: item))
    }

    await store.send(.destination(.presented(.add(.cancelButtonTapped)))) {
      $0.destination = nil
    }
  }

  @Test
  func testEditItem() async {
    let item = ListScreenItem.mock
    let store = TestStore(
      initialState: ListScreenFeature.State(items: [item])
    ) {
      ListScreenFeature()
    } withDependencies: {
      $0.listScreenClient.saveItems = { _ in }
    }

    await store.send(.itemTapped(item.id)) {
      $0.destination = .edit(ListScreenEditItem.State(item: item))
    }

    var editedItem = item
    editedItem.title = "Updated Title"

    await store.send(.destination(.presented(.edit(.saveButtonTapped(editedItem))))) {
      $0.destination = nil
      $0.items[id: item.id]?.title = "Updated Title"
    }
  }

  @Test
  func testEditItem_Cancel() async {
    let item = ListScreenItem.mock
    let store = TestStore(
      initialState: ListScreenFeature.State(items: [item])
    ) {
      ListScreenFeature()
    }

    await store.send(.itemTapped(item.id)) {
      $0.destination = .edit(ListScreenEditItem.State(item: item))
    }

    await store.send(.destination(.presented(.edit(.cancelButtonTapped)))) {
      $0.destination = nil
    }
  }

  @Test
  func testDeleteItem() async {
    let item = ListScreenItem.mock
    let store = TestStore(
      initialState: ListScreenFeature.State(items: [item])
    ) {
      ListScreenFeature()
    } withDependencies: {
      $0.listScreenClient.saveItems = { _ in }
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

  @Test
  func testSortItems() async {
    let items: IdentifiedArrayOf<ListScreenItem> = [
      ListScreenItem(id: UUID(0), title: "B Item", description: "", createdAt: Date(timeIntervalSince1970: 2)),
      ListScreenItem(id: UUID(1), title: "A Item", description: "", createdAt: Date(timeIntervalSince1970: 1)),
    ]

    let store = TestStore(
      initialState: ListScreenFeature.State(items: items)
    ) {
      ListScreenFeature()
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

  @Test
  func testFilterItems() async {
    let items = ListScreenItem.mocks
    let store = TestStore(
      initialState: ListScreenFeature.State(items: items)
    ) {
      ListScreenFeature()
    }

    await store.send(.setFilterCriteria(ListScreenFilterCriteria(searchText: "First"))) {
      $0.filterCriteria = ListScreenFilterCriteria(searchText: "First")
    }
  }
}
