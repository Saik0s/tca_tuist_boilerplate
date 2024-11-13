import Foundation
import ProjectDescription

public struct ProjectEnvironment {
    public let organizationName: String
    public let destinations: Destinations
    public let deploymentTargets: DeploymentTargets
}

public let env = ProjectEnvironment(
    organizationName: "dev.tarasenko",
    destinations: [.iPhone, .iPad],
    deploymentTargets: .iOS("18.0")
)
