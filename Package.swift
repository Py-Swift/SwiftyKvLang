// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyKvLang",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        // KV language parser library
        .library(
            name: "KvParser",
            targets: ["KvParser"]
        ),
        // Performance benchmark executable
        .executable(
            name: "benchmark",
            targets: ["Benchmark"]
        ),
    ],
    dependencies: [
        // Reference PySwiftAST for expression parsing patterns
        // Uncomment if we decide to reuse Python expression parser
        // .package(path: "./PySwiftAST")
    ],
    targets: [
        // KV language parser target
        .target(
            name: "KvParser",
            dependencies: [],
            path: "Sources/KvParser"
        ),
        
        // Performance benchmark executable
        .executableTarget(
            name: "Benchmark",
            dependencies: ["KvParser"],
            path: "Sources/Benchmark"
        ),
        
        // Tests for KV parser
        .testTarget(
            name: "KvParserTests",
            dependencies: ["KvParser"],
            path: "Tests/KvParserTests",
            resources: [
                .copy("Resources/style.kv")
            ]
        ),
    ]
)
