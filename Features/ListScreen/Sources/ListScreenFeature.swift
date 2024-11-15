//
// ListScreenFeature.swift
//

import ComposableArchitecture
import ListScreenInterface
import SwiftUI
import TaskProcessor

// MARK: - ListScreenFeature

@Reducer
public struct ListScreenFeature {
  @ObservableState
  public struct State: Equatable {
    var items: IdentifiedArrayOf<ListScreenItem> = []
    var isLoading = false
    var sortOrder: ListScreenSortOrder = .custom
    var filterCriteria: ListScreenFilterCriteria?
    @Presents var destination: Destination.State?

    public init(
      items: IdentifiedArrayOf<ListScreenItem> = [],
      isLoading: Bool = false,
      sortOrder: ListScreenSortOrder = .custom,
      filterCriteria: ListScreenFilterCriteria? = nil
    ) {
      self.items = items
      self.isLoading = isLoading
      self.sortOrder = sortOrder
      self.filterCriteria = filterCriteria
    }
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case add(ListScreenAddItem)
    case edit(ListScreenEditItem)
    case alert(AlertState<Alert>)

    @CasePathable
    public enum Alert: Equatable {
      case confirmDeletion(ListScreenItem.ID)
    }
  }

  public enum Action {
    case onAppear
    case itemsResponse(TaskResult<IdentifiedArrayOf<ListScreenItem>>)
    case addButtonTapped
    case destination(PresentationAction<Destination.Action>)
    case itemTapped(ListScreenItem.ID)
    case moveItem(from: IndexSet, to: Int)
    case deleteItem(IndexSet)
    case setSortOrder(ListScreenSortOrder)
    case setFilterCriteria(ListScreenFilterCriteria?)
  }

  @Dependency(\.listScreenClient) var client
  @Dependency(\.date) var date
  @Dependency(\.uuid) var uuid

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { send in
          await send(.itemsResponse(TaskResult { try await client.fetchItems() }))
        }

      case let .itemsResponse(.success(items)):
        state.isLoading = false
        state.items = IdentifiedArray(uniqueElements: items)
        return .none

      case .itemsResponse(.failure):
        state.isLoading = false
        state.destination = .alert(
          AlertState(
            title: { TextState("Error") },
            actions: { ButtonState(role: .cancel) { TextState("OK") } },
            message: { TextState("Failed to load items") }
          )
        )
        return .none

      case .addButtonTapped:
        let item = ListScreenItem(
          id: uuid(),
          title: "New Item",
          description: "",
          createdAt: date()
        )
        state.destination = .add(ListScreenAddItem.State(item: item))
        return .none

      case let .destination(.presented(.add(.saveButtonTapped(item)))):
        state.items.append(item)
        state.destination = nil
        return .run { [items = state.items] _ in
          try await client.saveItems(Array(items))
        }

      case let .itemTapped(id):
        guard let item = state.items[id: id] else { return .none }
        state.destination = .edit(ListScreenEditItem.State(item: item))
        return .none

      case let .destination(.presented(.edit(.saveButtonTapped(item)))):
        state.items[id: item.id] = item
        state.destination = nil
        return .run { [items = state.items] _ in
          try await client.saveItems(Array(items))
        }

      case let .moveItem(from, to):
        state.items.move(fromOffsets: from, toOffset: to)
        return .run { [items = state.items] _ in
          try await client.saveItems(Array(items))
        }

      case let .deleteItem(indexSet):
        let id = state.items[indexSet.first!].id
        state.destination = .alert(
          AlertState(
            title: { TextState("Delete Item") },
            actions: {
              ButtonState(role: .destructive, action: .confirmDeletion(id)) {
                TextState("Delete")
              }
              ButtonState(role: .cancel) {
                TextState("Cancel")
              }
            },
            message: { TextState("Are you sure you want to delete this item?") }
          )
        )
        return .none

      case let .destination(.presented(.alert(.confirmDeletion(id)))):
        state.items.remove(id: id)
        return .run { [items = state.items] _ in
          try await client.saveItems(Array(items))
        }

      case let .setSortOrder(order):
        state.sortOrder = order
        state.items.sort { lhs, rhs in
          switch order {
          case .alphabetical: lhs.title < rhs.title
          case .date: lhs.createdAt < rhs.createdAt
          case .custom: true
          }
        }
        return .none

      case let .setFilterCriteria(criteria):
        state.filterCriteria = criteria
        return .none

      case .destination(.presented(.add(.cancelButtonTapped))),
           .destination(.presented(.edit(.cancelButtonTapped))):
        state.destination = nil
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}
