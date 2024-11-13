//
// ListScreenFeature.swift
//

import ComposableArchitecture
import ListScreenInterface
import SwiftUI

// MARK: - ListScreenFeature

@Reducer
public struct ListScreenFeature {
    @ObservableState
    public struct State {
        var items: IdentifiedArrayOf<Item> = []
        var isLoading = false
        var sortOrder: ListSortOrder = .custom
        var filterCriteria: FilterCriteria?
        @Presents var destination: Destination.State?

        public init() {}
    }

    @Reducer
    public enum Destination {
        case add(AddItem)
        case edit(EditItem)
        case alert(AlertState<Alert>)

        @CasePathable
        public enum Alert: Equatable {
            case confirmDeletion(Item.ID)
        }
    }

    public enum Action {
        case onAppear
        case itemsResponse(TaskResult<[Item]>)
        case addButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case itemTapped(Item.ID)
        case moveItem(from: IndexSet, to: Int)
        case deleteItem(IndexSet)
        case setSortOrder(ListSortOrder)
        case setFilterCriteria(FilterCriteria?)
    }

    @Dependency(\.client) var client

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
                    AlertState(title: { TextState("Error") },
                               actions: { ButtonState(role: .cancel) { TextState("OK") } },
                               message: { TextState("Failed to load items") })
                )
                return .none

            case .addButtonTapped:
                state.destination = .add(AddItem.State())
                return .none

            case let .destination(.presented(.add(.saveButtonTapped(item)))):
                state.items.append(item)
                state.destination = nil
                return .run { [items = state.items] _ in
                    try await client.saveItems(Array(items))
                }

            case let .itemTapped(id):
                guard let item = state.items[id: id] else { return .none }
                state.destination = .edit(EditItem.State(item: item))
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
                    AlertState(title: { TextState("Delete Item") },
                               actions: {
                                   ButtonState(role: .destructive, action: .confirmDeletion(id)) {
                                       TextState("Delete")
                                   }
                                   ButtonState(role: .cancel) {
                                       TextState("Cancel")
                                   }
                               },
                               message: { TextState("Are you sure you want to delete this item?") })
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

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - AddItem

@Reducer
public struct AddItem {
    @ObservableState
    public struct State: Equatable {
        public var item = Item(id: UUID(), title: "", description: "", createdAt: Date())

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case saveButtonTapped(Item)
        case cancelButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .binding:
                .none
            case .cancelButtonTapped, .saveButtonTapped:
                .none
            }
        }
    }
}

// MARK: - EditItem

@Reducer
public struct EditItem {
    @ObservableState
    public struct State: Equatable {
        public var item: Item

        public init(item: Item) {
            self.item = item
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case saveButtonTapped(Item)
        case cancelButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .binding:
                .none
            case .cancelButtonTapped, .saveButtonTapped:
                .none
            }
        }
    }
}
