import ComposableArchitecture
import ListScreenInterface

@Reducer
public struct ListScreenEditItem {
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
        return .none
      case .cancelButtonTapped, .saveButtonTapped:
        return .none
      }
    }
  }
}
