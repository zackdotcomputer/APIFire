// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APIFire",
    // Replicating Alamofire's supported platforms
    platforms: [.macOS(.v10_13),
                .iOS(.v11),
                .tvOS(.v11),
                .watchOS(.v4)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "APIFire",
            targets: ["APIFire"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "APIFire",
            dependencies: [
                "Alamofire",
            ],
            path: "Source"
        ),
        .testTarget(
            name: "APIFireTests",
            dependencies: ["APIFire"]),
    ],
    swiftLanguageVersions: [.v5]
)
