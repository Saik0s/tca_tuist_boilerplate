//
// ComponentView.swift
//

import ComposableArchitecture
import SwiftUI

public struct ComponentView: View {
  let store: StoreOf<Component>

  public init(store: StoreOf<Component>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      VStack {
        Text("Component View")
      }
    }
  }
}

#Preview {
  ComponentView(
    store: Store(
      initialState: Component.State()
    ) {
      Component()
    }
  )
}
