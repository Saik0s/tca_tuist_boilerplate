import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
  description: """
    Creates a library module for handling long-running background tasks with:
    - Real-time progress tracking
    - Task queue management 
    - Cancellation support
    - Pause/Resume functionality
    - Proper dependency management
    """,
  attributes: [
    nameAttribute
  ],
  items: [
    // Project configuration
    .file(path: "Project.swift", templatePath: "project.stencil"),
    
    // Core implementation
    .file(path: "Sources/\(nameAttribute)Client.swift", templatePath: "client.stencil"),
    .file(path: "Sources/\(nameAttribute)Models.swift", templatePath: "models.stencil"),
    .file(path: "Sources/Live\(nameAttribute)Client.swift", templatePath: "live_client.stencil"),
    
    // Tests
    .file(path: "Tests/\(nameAttribute)Tests.swift", templatePath: "tests.stencil")
  ]
)
