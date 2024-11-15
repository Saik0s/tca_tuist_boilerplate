//
// ListScreenAddItemFeature.swift
//

import ComposableArchitecture
import ListScreenInterface

@Reducer
public struct ListScreenAddItem {
  @ObservableState
  public struct State: Equatable {
    public var item: ListScreenItem

    public init(item: ListScreenItem) {
      self.item = item
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case saveButtonTapped(ListScreenItem)
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
