//
// Project.swift
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "ListScreen",
  options: .options(
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),
  targets: [
    .target(
      name: "ListScreen",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).ListScreen",
      deploymentTargets: env.deploymentTargets,
      sources: ["Sources/**"],
      dependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "Inject"),
        .target(name: "ListScreenInterface"),
        .target(name: "ListScreenTesting"),
      ]
    ),
    .target(
      name: "ListScreenInterface",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).ListScreenInterface",
      deploymentTargets: env.deploymentTargets,
      sources: ["Interface/Sources/**"],
      dependencies: [
        .external(name: "Dependencies"),
        .external(name: "DependenciesMacros"),
        .external(name: "IdentifiedCollections"),
      ]
    ),
    .target(
      name: "ListScreenTesting",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).ListScreenTesting",
      deploymentTargets: env.deploymentTargets,
      sources: ["Testing/Sources/**"],
      dependencies: [
        .target(name: "ListScreenInterface"),
      ]
    ),
    .target(
      name: "ListScreenTests",
      destinations: env.destinations,
      product: .unitTests,
      bundleId: "\(env.organizationName).ListScreenTests",
      deploymentTargets: env.deploymentTargets,
      sources: ["Tests/**"],
      dependencies: [
        .target(name: "ListScreen"),
        .target(name: "ListScreenTesting"),
        .external(name: "SnapshotTesting"),
      ]
    ),
  ]
)
