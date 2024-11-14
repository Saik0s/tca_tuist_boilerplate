//
// ComponentTests.swift
//

@testable import Component
import ComposableArchitecture
import XCTest

final class ComponentTests: XCTestCase {
  @MainActor
  func testInitialState() async {
    let store = TestStore(initialState: Component.State()) {
      Component()
    }

    await store.send(.onAppear)
  }
}
