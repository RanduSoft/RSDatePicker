// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RSDatePicker",
	platforms: [.iOS(.v13)],
    products: [
        .library(name: "RSDatePicker", targets: ["RSDatePicker"]),
    ],
    targets: [
		.target(name: "RSDatePicker", path: "Files"),
    ]
)
