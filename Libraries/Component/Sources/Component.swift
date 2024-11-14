//
// Component.swift
//

import ComposableArchitecture
import Foundation

@Reducer
public struct Component {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        .none
      }
    }
  }
}
