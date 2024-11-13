import SwiftUI
import ComposableArchitecture
import ListScreenInterface
import Inject

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
                AddItemView(store: addStore)
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.edit, action: \.destination.edit)
        ) { editStore in
            NavigationStack {
                EditItemView(store: editStore)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .onAppear { store.send(.onAppear) }
        .enableInjection()
    }
}

struct AddItemView: View {
    @ObserveInjection var inject
    @Bindable var store: StoreOf<AddItem>

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

struct EditItemView: View {
    @ObserveInjection var inject
    @Bindable var store: StoreOf<EditItem>

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