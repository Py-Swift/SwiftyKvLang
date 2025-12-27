// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KvToPyClass",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "KvToPyClass",
            targets: ["KvToPyClass"]
        ),
        .executable(
            name: "kvtoclass",
            targets: ["KvToPyClassCLI"]
        )
    ],
    dependencies: [
        // Local dependency on SwiftyKvLang parser
        .package(path: ".."),
        // PySwiftAST for generating Python code
        .package(url: "https://github.com/Py-Swift/PySwiftAST.git", branch: "master")
    ],
    targets: [
        .target(
            name: "KivyWidgetRegistry",
            dependencies: [],
            path: "Sources/KivyWidgetRegistry"
        ),
        .target(
            name: "KvToPyClass",
            dependencies: [
                "KivyWidgetRegistry",
                .product(name: "KvParser", package: "SwiftyKvLang"),
                .product(name: "PySwiftAST", package: "PySwiftAST"),
                .product(name: "PySwiftCodeGen", package: "PySwiftAST"),
                .product(name: "PyFormatters", package: "PySwiftAST")
            ],
            path: "Sources/KvToPyClass"
        ),
        .executableTarget(
            name: "KvToPyClassCLI",
            dependencies: ["KvToPyClass", "KivyWidgetRegistry"],
            path: "Sources/KvToPyClassCLI"
        ),
        .testTarget(
            name: "KvToPyClassTests",
            dependencies: ["KvToPyClass", "KivyWidgetRegistry"],
            path: "Tests/KvToPyClassTests"
        )
    ]
)
