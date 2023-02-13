// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stardust",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Stardust",
            targets: ["Stardust"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(name: "Sandbox", dependencies: ["Stardust"]),
        .target(
            name: "Stardust",
            dependencies: ["CVulkan", "CGLFW", "CStardust", "SML"],
            linkerSettings: [
                .linkedLibrary("Bin/glfw3"),
                .linkedLibrary("Bin/vulkan"),
                .linkedLibrary("user32",   .when(platforms: [.windows])),
                .linkedLibrary("gdi32",    .when(platforms: [.windows])),
                .linkedLibrary("kernel32", .when(platforms: [.windows])),
            ]
            ),
        .target(name: "SML"),
        .target(
            name: "CStardust",
            path: "Libs/CStardust"
        ),
        .systemLibrary(name: "CVulkan", path: "Libs/CVulkan"),
        .systemLibrary(name: "CGLFW", path: "Libs/CGLFW"),
        .testTarget(
            name: "StardustTests",
            dependencies: ["Stardust"]),
    ]
)
