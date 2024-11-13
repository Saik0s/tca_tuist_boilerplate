// swift-tools-version: 6.0
import PackageDescription

#if TUIST
  import struct ProjectDescription.PackageSettings

  let packageSettings = PackageSettings(
    // Customize the product types for specific package product
    // Default is .staticFramework
    // productTypes: ["Alamofire": .framework,]
    productTypes: [:]
  )
#endif

let package = Package(
  name: "TCATuistBoilerplate",
  dependencies: [
    .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.5.2"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.15.2"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.5"),
  ]
)
