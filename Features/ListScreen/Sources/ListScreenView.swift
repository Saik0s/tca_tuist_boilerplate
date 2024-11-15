//
// ListScreenView.swift
//

import ComposableArchitecture
import Inject
import ListScreenInterface
import SwiftUI

// MARK: - ListScreenView

public struct ListScreenView: View {
  @ObserveInjection var inject
  @Bindable var store: StoreOf<ListScreenFeature>

  public init(store: StoreOf<ListScreenFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      List {
        ForEach(store.items) { item in
          ListScreenItemView(item: item)
            .onTapGesture { store.send(.itemTapped(item.id)) }
        }
        .onDelete { store.send(.deleteItem($0)) }
        .onMove { store.send(.moveItem(from: $0, to: $1)) }
      }
      .navigationTitle("ListScreen")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Add") { store.send(.addButtonTapped) }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          EditButton()
        }
      }
      .overlay {
        if store.isLoading {
          ProgressView()
        }
      }
    }
    .sheet(
      item: $store.scope(state: \.destination?.add, action: \.destination.add)
    ) { addStore in
      NavigationStack {
        ListScreenAddItemView(store: addStore)
      }
    }
    .sheet(
      item: $store.scope(state: \.destination?.edit, action: \.destination.edit)
    ) { editStore in
      NavigationStack {
        ListScreenEditItemView(store: editStore)
      }
    }
    .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    .onAppear { store.send(.onAppear) }
    .enableInjection()
  }
}

// MARK: - ListScreenAddItemView

struct ListScreenAddItemView: View {
  @ObserveInjection var inject
  @Bindable var store: StoreOf<ListScreenAddItem>

  var body: some View {
    Form {
      TextField("Title", text: $store.item.title)
      TextField("Description", text: $store.item.description)
    }
    .navigationTitle("Add Item")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { store.send(.cancelButtonTapped) }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") { store.send(.saveButtonTapped(store.item)) }
      }
    }
    .enableInjection()
  }
}

// MARK: - ListScreenEditItemView

struct ListScreenEditItemView: View {
  @ObserveInjection var inject
  @Bindable var store: StoreOf<ListScreenEditItem>

  var body: some View {
    Form {
      TextField("Title", text: $store.item.title)
      TextField("Description", text: $store.item.description)
    }
    .navigationTitle("Edit Item")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { store.send(.cancelButtonTapped) }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") { store.send(.saveButtonTapped(store.item)) }
      }
    }
    .enableInjection()
  }
}
