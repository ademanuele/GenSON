// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "GenSON",
    products: [
        .library(
            name: "GenSON",
            targets: ["GenSON"]),
    ],
    targets: [
        .target(
            name: "GenSON"),
        .testTarget(
            name: "GenSONTests",
            dependencies: ["GenSON"]
        ),
    ]
)
