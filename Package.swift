// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DisplayControl",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "DisplayControl",
            targets: ["DisplayControl"]
        )
    ],
    targets: [
        .executableTarget(
            name: "DisplayControl",
            path: "Sources/DisplayControl"
        )
    ]
)
