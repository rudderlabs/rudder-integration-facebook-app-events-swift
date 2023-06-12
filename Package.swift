// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RudderFacebookAppEvents",
    platforms: [
        .iOS("12.0"), .tvOS("11.0")
    ],
    products: [
        .library(
            name: "RudderFacebookAppEvents",
            targets: ["RudderFacebookAppEvents"]
        )
    ],
    dependencies: [
        .package(name: "Facebook", url: "https://github.com/facebook/facebook-ios-sdk", "14.0.0"..<"14.0.1"),
        .package(name: "Rudder", url: "https://github.com/rudderlabs/rudder-sdk-ios", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RudderFacebookAppEvents",
            dependencies: [
                .product(name: "FacebookCore", package: "Facebook"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Sources",
            sources: ["Classes/"]
        )
    ]
)
