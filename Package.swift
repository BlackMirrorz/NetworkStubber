// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "NetworkStubberPackage",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "NetworkStubberPackage",
      targets: ["NetworkStubberPackage"]
    )
  ],
  targets: [
    .target(
      name: "NetworkStubberPackage"),
    .testTarget(
      name: "NetworkStubberPackageTests",
      dependencies: ["NetworkStubberPackage"]
    )
  ]
)
