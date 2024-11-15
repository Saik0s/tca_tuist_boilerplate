//
// ListScreenSnapshotTests.swift
//

import ComposableArchitecture
@testable import ListScreen
import ListScreenInterface
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class ListScreenSnapshotTests: XCTestCase {
  func testListScreenView() async {
    let view = ListScreenView(store: .init(initialState: ListScreenFeature.State(items: ListScreenItem.mocks)) {})

    assertSnapshot(
      of: view,
      as: .image(precision: 0.98, layout: .device(config: .iPhoneXsMax)),
      named: "default"
    )

    // Test loading state
    let loadingView = ListScreenView(store: .init(initialState: ListScreenFeature.State(isLoading: true)) {})
    assertSnapshot(
      of: loadingView,
      as: .image(precision: 0.98, layout: .device(config: .iPhoneXsMax)),
      named: "loading"
    )

    // Test empty state
    let emptyView = ListScreenView(store: .init(initialState: ListScreenFeature.State()) {})
    assertSnapshot(
      of: emptyView,
      as: .image(precision: 0.98, layout: .device(config: .iPhoneXsMax)),
      named: "empty"
    )
  }

  func testListScreenAddItemView() {
    let view = NavigationStack {
      ListScreenAddItemView(store: .init(initialState: ListScreenAddItem.State(item: ListScreenItem.mock)) {})
    }

    assertSnapshot(
      of: view,
      as: .image(precision: 0.98, layout: .device(config: .iPhoneXsMax)),
      named: "default"
    )
  }

  func testListScreenEditItemView() {
    let view = NavigationStack {
      ListScreenEditItemView(store: .init(initialState: ListScreenEditItem.State(item: ListScreenItem.mock)) {})
    }

    assertSnapshot(
      of: view,
      as: .image(precision: 0.98, layout: .device(config: .iPhoneXsMax)),
      named: "default"
    )
  }
}
