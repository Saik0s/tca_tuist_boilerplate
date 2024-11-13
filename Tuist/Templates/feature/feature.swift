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
    .file(path: "Features/\(nameAttribute)/Project.swift", templatePath: "project.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)Feature.swift", templatePath: "Feature.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)View.swift", templatePath: "View.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/\(nameAttribute)ItemView.swift", templatePath: "ItemView.stencil"),
    .file(path: "Features/\(nameAttribute)/Sources/Live\(nameAttribute)Client.swift", templatePath: "Client.stencil"),
    .file(path: "Features/\(nameAttribute)/Interface/Sources/\(nameAttribute)Models.swift", templatePath: "InterfaceModels.stencil"),
    .file(path: "Features/\(nameAttribute)/Interface/Sources/\(nameAttribute)Client.swift", templatePath: "InterfaceClient.stencil"),
    .file(path: "Features/\(nameAttribute)/Testing/Sources/\(nameAttribute)Testing.swift", templatePath: "Testing.stencil"),
    .file(path: "Features/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", templatePath: "Tests.stencil"),
  ]
)
