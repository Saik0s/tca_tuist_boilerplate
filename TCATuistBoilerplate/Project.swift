//
// Project.swift
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "TCATuistBoilerplate",
  options: .options(
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),
  targets: [
    .target(
      name: "TCATuistBoilerplate",
      destinations: env.destinations,
      product: .app,
      bundleId: "\(env.organizationName).TCATuistBoilerplate",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
          ]
        ]
      ),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "ListScreen", path: "../Features/ListScreen"),
        .external(name: "ComposableArchitecture"),
      ]
    ),
    .target(
      name: "TCATuistBoilerplateTests",
      destinations: env.destinations,
      product: .unitTests,
      bundleId: "\(env.organizationName).TCATuistBoilerplateTests",
      deploymentTargets: env.deploymentTargets,
      infoPlist: .default,
      sources: ["Tests/**"],
      resources: [],
      dependencies: [.target(name: "TCATuistBoilerplate")]
    ),
  ]
)
