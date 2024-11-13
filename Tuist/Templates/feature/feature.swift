//
// feature.swift
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
    .file(path: "Features/\(nameAttribute)/Project.swift", templatePath: "project.stencil"),

    // Interface files
    .file(path: "Features/\(nameAttribute)/Interface/\(nameAttribute)Client.swift", templatePath: "InterfaceClient.stencil"),
    .file(path: "Features/\(nameAttribute)/Interface/\(nameAttribute)Models.swift", templatePath: "InterfaceModels.stencil"),

    // Source files
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)Feature.swift", templatePath: "Feature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)View.swift", templatePath: "View.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)ItemView.swift", templatePath: "ItemView.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)AddItemFeature.swift", templatePath: "AddItemFeature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)EditItemFeature.swift", templatePath: "EditItemFeature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/Live\(nameAttribute)Client.swift", templatePath: "LiveClient.stencil"),

    // Testing files
    .file(path: "Features/\(nameAttribute)/Testing/\(nameAttribute)Testing.swift", templatePath: "Testing.stencil"),
    .file(path: "Features/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", templatePath: "Tests.stencil"),
  ]
)
