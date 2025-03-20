// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "NetworkStubber",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "NetworkStubber",
      targets: ["NetworkStubber"]
    )
  ],
  targets: [
    .target(
      name: "NetworkStubber"),
    .testTarget(
      name: "NetworkStubberTests",
      dependencies: ["NetworkStubber"]
    )
  ]
)
