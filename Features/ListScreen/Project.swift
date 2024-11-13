import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ListScreen",
    targets: [
        .target(
            name: "ListScreen",
            destinations: env.destinations,
            product: .framework,
            bundleId: "\(env.organizationName).ListScreen",
            deploymentTargets: env.deploymentTargets,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "Inject"),
                .target(name: "ListScreenInterface"),
            ]
        ),
        .target(
            name: "ListScreenInterface",
            destinations: env.destinations,
            product: .framework,
            bundleId: "\(env.organizationName).ListScreenInterface",
            deploymentTargets: env.deploymentTargets,
            sources: ["Interface/Sources/**"]
        ),
        .target(
            name: "ListScreenTesting",
            destinations: env.destinations,
            product: .framework,
            bundleId: "\(env.organizationName).ListScreenTesting",
            deploymentTargets: env.deploymentTargets,
            sources: ["Testing/Sources/**"],
            dependencies: [
                .target(name: "ListScreen"),
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
