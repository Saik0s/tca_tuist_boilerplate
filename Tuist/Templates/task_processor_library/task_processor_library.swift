import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
  description: "A Swift async/await task processing library with real-time progress tracking, FIFO queue management, and task control (pause/resume/cancel) built on modern Swift concurrency.",
  attributes: [
    nameAttribute
  ],
  items: [
    // Project configuration
    .file(path: "Libraries/\(nameAttribute)/Project.swift", templatePath: "Project.stencil"),

    // Interface files
    .file(path: "Libraries/\(nameAttribute)/Interface/\(nameAttribute)Client.swift", templatePath: "Interface/Client.stencil"),
    .file(path: "Libraries/\(nameAttribute)/Interface/\(nameAttribute)Models.swift", templatePath: "Interface/Models.stencil"),
    .file(path: "Libraries/\(nameAttribute)/Interface/\(nameAttribute)Operation.swift", templatePath: "Interface/Operation.stencil"),

    // Source files
    .file(path: "Libraries/\(nameAttribute)/Sources/Live\(nameAttribute)Client.swift", templatePath: "Sources/LiveClient.stencil"),
    .file(path: "Libraries/\(nameAttribute)/Sources/TaskManager.swift", templatePath: "Sources/TaskManager.stencil"),

    // Tests
    .file(path: "Libraries/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", templatePath: "Tests/Tests.stencil")
  ]
)
