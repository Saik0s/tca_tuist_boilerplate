//
// ComponentSnapshotTests.swift
//

@testable import Component
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

final class ComponentSnapshotTests: XCTestCase {
  func testDefaultState() {
    let view = ComponentView(
      store: Store(initialState: Component.State()) {}
    )

    assertSnapshot(
      of: view,
      as: .image(layout: .device(config: .iPhone13)),
      named: "default"
    )
  }
}
