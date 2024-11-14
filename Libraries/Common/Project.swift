//
// Project.swift
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Common",
  options: .options(
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),
  targets: [
    .target(
      name: "Common",
      destinations: env.destinations,
      product: .staticFramework,
      bundleId: "\(env.organizationName).Common",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .external(name: "ComposableArchitecture"),
      ]
    ),
    .target(
      name: "CommonTests",
      destinations: env.destinations,
      product: .unitTests,
      bundleId: "\(env.organizationName).CommonTests",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Tests/**"],
      dependencies: [
        .target(name: "Common"),
      ]
    ),
  ]
)
