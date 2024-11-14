//
// Project.swift
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "TaskProcessor",
  options: .options(
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),
  targets: [
    .target(
      name: "TaskProcessor",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).TaskProcessor",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .external(name: "Dependencies"),
        .external(name: "ComposableArchitecture"),
        .target(name: "TaskProcessorInterface"),
      ]
    ),
    .target(
      name: "TaskProcessorInterface",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).TaskProcessorInterface",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Interface/**"],
      dependencies: [
        .external(name: "Dependencies"),
        .external(name: "ComposableArchitecture"),
      ]
    ),
    .target(
      name: "TaskProcessorTests",
      destinations: env.destinations,
      product: .unitTests,
      bundleId: "\(env.organizationName).TaskProcessorTests",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Tests/**"],
      dependencies: [
        .target(name: "TaskProcessor"),
        .target(name: "TaskProcessorInterface"),
        .external(name: "ComposableArchitecture"),
      ]
    ),
  ]
)
