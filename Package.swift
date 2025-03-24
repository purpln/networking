// swift-tools-version: 6.0

import PackageDescription

let package = Package(name: "Networking", products: [
    .library(name: "Networking", targets: ["Socket"]),
], dependencies: [
    .package(url: "https://github.com/purpln/libc.git", branch: "main"),
], targets: [
    .target(name: "Socket", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
])
