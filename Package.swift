// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Bluebird",
    products: [
        .library(name: "Bluebird", targets: ["Bluebird"])
    ],
    targets: [
        .target(
            name: "Bluebird",
            dependencies: [],
            path: "./Sources"
        ),
        .testTarget(
            name: "BluebirdTests",
            dependencies: ["Bluebird"],
            path: "./Tests"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
