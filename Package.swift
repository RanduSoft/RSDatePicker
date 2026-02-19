// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "RSDatePicker",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "RSDatePicker", targets: ["RSDatePicker"])
    ],
    targets: [
		.target(name: "RSDatePicker")
    ]
)
