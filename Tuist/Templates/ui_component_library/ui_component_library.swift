import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
  description: "A SwiftUI component library with unit and snapshot testing support",
  attributes: [
    nameAttribute
  ],
  items: [
    // Project configuration
    .file(path: "Libraries/\(nameAttribute)/Project.swift", templatePath: "Project.stencil"),

    // Source files
    .file(path: "Libraries/\(nameAttribute)/Sources/\(nameAttribute)View.swift", templatePath: "Sources/View.stencil"),
    .file(path: "Libraries/\(nameAttribute)/Sources/\(nameAttribute).swift", templatePath: "Sources/Feature.stencil"),

    // Tests
    .file(path: "Libraries/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", templatePath: "Tests/Tests.stencil"),
    .file(path: "Libraries/\(nameAttribute)/Tests/\(nameAttribute)SnapshotTests.swift", templatePath: "Tests/SnapshotTests.stencil")
  ]
)
