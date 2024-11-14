//
// Project.swift
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Component",
  options: .options(
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),
  targets: [
    .target(
      name: "Component",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).Component",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .external(name: "ComposableArchitecture"),
      ]
    ),
    .target(
      name: "ComponentTests",
      destinations: env.destinations,
      product: .unitTests,
      bundleId: "\(env.organizationName).ComponentTests",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Tests/**"],
      dependencies: [
        .target(name: "Component"),
        .external(name: "SnapshotTesting"),
      ]
    ),
  ]
)
