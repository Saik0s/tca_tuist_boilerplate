import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
  description: """
    Creates a library module with task queue processing capabilities.
    Includes real-time progress tracking, cancellation, and pause/resume functionality.
    """,
  attributes: [
    nameAttribute,
    .optional("include_tests", default: true),
    .optional("include_persistence", default: false)
  ],
  items: [
    // Core files
    .file(path: "Project.swift", templatePath: "project.stencil"),
    .file(path: "Interface/\(nameAttribute)Client.swift", templatePath: "client.stencil"),
    .file(path: "Interface/\(nameAttribute)Models.swift", templatePath: "models.stencil"),
    .file(path: "Sources/\(nameAttribute)Feature.swift", templatePath: "feature.stencil"),
    .file(path: "Sources/Live\(nameAttribute)Client.swift", templatePath: "live_client.stencil"),
    
    // Testing support
    .file(
      path: "Testing/\(nameAttribute)Testing.swift",
      templatePath: "testing.stencil",
      condition: .attributeMatch("include_tests", true)
    ),
    .file(
      path: "Tests/\(nameAttribute)Tests.swift",
      templatePath: "tests.stencil",
      condition: .attributeMatch("include_tests", true)
    ),
    
    // Optional persistence support
    .file(
      path: "Sources/\(nameAttribute)Storage.swift", 
      templatePath: "storage.stencil",
      condition: .attributeMatch("include_persistence", true)
    )
  ]
)
