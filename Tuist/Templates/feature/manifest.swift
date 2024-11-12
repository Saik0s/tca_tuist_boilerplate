import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")
let platformAttribute: Template.Attribute = .optional("platform", default: "ios")
let organizationAttribute: Template.Attribute = .optional("organizationName", default: "organization")

let template = Template(
    description: "TCA Feature template with interactive list",
    attributes: [
        nameAttribute,
        platformAttribute,
        organizationAttribute
    ],
    items: [
        .file(path: "Project.swift", templatePath: "project.stencil"),
        .file(path: "Sources/\(nameAttribute)Feature.swift", templatePath: "Feature.stencil"),
        .file(path: "Sources/\(nameAttribute)View.swift", templatePath: "View.stencil"),
        .file(path: "Sources/\(nameAttribute)ItemView.swift", templatePath: "ItemView.stencil"),
        .file(path: "Sources/\(nameAttribute)Client.swift", templatePath: "Client.stencil"),
        .file(path: "Interface/Sources/\(nameAttribute)Interface.swift", templatePath: "Interface.stencil"),
        .file(path: "Testing/Sources/\(nameAttribute)Testing.swift", templatePath: "Testing.stencil"),
        .file(path: "Tests/\(nameAttribute)Tests.swift", templatePath: "Tests.stencil"),
    ]
)
