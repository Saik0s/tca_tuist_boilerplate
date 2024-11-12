import ProjectDescription

let project = Project(
    name: "TCATuistBoilerplate",
    targets: [
        .target(
            name: "TCATuistBoilerplate",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.TCATuistBoilerplate",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["TCATuistBoilerplate/Sources/**"],
            resources: ["TCATuistBoilerplate/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TCATuistBoilerplateTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.TCATuistBoilerplateTests",
            infoPlist: .default,
            sources: ["TCATuistBoilerplate/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TCATuistBoilerplate")]
        ),
    ]
)
