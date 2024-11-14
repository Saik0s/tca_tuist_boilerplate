import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
    description: "A simple Swift library with unit testing support",
    attributes: [
        nameAttribute
    ],
    items: [
        // Project configuration
        .file(path: "Libraries/\(nameAttribute)/Project.swift", templatePath: "Project.stencil"),

        // Source files
        .file(path: "Libraries/\(nameAttribute)/Sources/\(nameAttribute).swift", templatePath: "Sources/Sources.stencil"),
        .file(path: "Libraries/\(nameAttribute)/Sources/\(nameAttribute)Extensions.swift", templatePath: "Sources/Extensions.stencil"),

        // Tests
        .file(path: "Libraries/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", templatePath: "Tests/Tests.stencil"),
        .file(path: "Libraries/\(nameAttribute)/Tests/\(nameAttribute)ExtensionsTests.swift", templatePath: "Tests/ExtensionsTests.stencil")
    ]
)
