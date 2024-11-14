//
// list_feature.swift
//

import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
  description: "TCA Feature template with interactive list",
  attributes: [
    nameAttribute,
  ],
  items: [
    // Project file
    .file(path: "Features/\(nameAttribute)/Project.swift", templatePath: "Project.stencil"),

    // Interface files
    .file(path: "Features/\(nameAttribute)/Interface/\(nameAttribute)Client.swift", templatePath: "Interface/Client.stencil"),
    .file(path: "Features/\(nameAttribute)/Interface/\(nameAttribute)Models.swift", templatePath: "Interface/Models.stencil"),

    // Source files
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)Feature.swift", templatePath: "Sources/Feature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)View.swift", templatePath: "Sources/View.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)ItemView.swift", templatePath: "Sources/ItemView.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)AddItemFeature.swift", templatePath: "Sources/AddItemFeature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)EditItemFeature.swift", templatePath: "Sources/EditItemFeature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/Live\(nameAttribute)Client.swift", templatePath: "Sources/LiveClient.stencil"),

    // Testing files
    .file(path: "Features/\(nameAttribute)/Testing/\(nameAttribute)Testing.swift", templatePath: "Testing/Testing.stencil"),
    .file(path: "Features/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", templatePath: "Tests/Tests.stencil"),
    .file(path: "Features/\(nameAttribute)/Tests/\(nameAttribute)SnapshotTests.swift", templatePath: "Tests/SnapshotTests.stencil"),
  ]
)
