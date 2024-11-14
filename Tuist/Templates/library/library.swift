import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
  description: "Creates a library module with essential components",
  attributes: [
    nameAttribute,
    .optional("include_tests", default: true)
  ],
  items: [
    // Core files
    .file(path: "Project.swift", templatePath: "project.stencil"),
    .file(path: "Sources/\(nameAttribute)Client.swift", templatePath: "client.stencil"),
    .file(path: "Sources/\(nameAttribute)Feature.swift", templatePath: "feature.stencil"),
    
    // Tests (conditional) 
    .file(
      path: "Tests/\(nameAttribute)Tests.swift",
      templatePath: "tests.stencil",
      condition: .attributeMatch("include_tests", true)
    )
  ]
)
