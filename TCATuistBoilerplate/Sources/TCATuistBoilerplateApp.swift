//
// TCATuistBoilerplateApp.swift
//

import ComposableArchitecture
import ListScreen
import SwiftUI

@main
struct TCATuistBoilerplateApp: App {
  // NB: This is static to avoid interference with Xcode previews, which create this entry
  //     point each time they are run.
  @MainActor static let store = Store(initialState: ListScreenFeature.State()) {
    ListScreenFeature()
      ._printChanges()
  } withDependencies: {
    if ProcessInfo.processInfo.environment["UITesting"] == "true" {
      $0.defaultFileStorage = .inMemory
    }
  }

  var body: some Scene {
    WindowGroup {
      if isTesting {
        // NB: Don't run application in tests to avoid interference between the app and the test.
        EmptyView()
      } else {
        ListScreenView(store: Self.store)
      }
    }
  }
}
