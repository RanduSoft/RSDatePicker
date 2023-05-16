// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RSDatePicker",
    platforms: [.iOS("13.2")],
    products: [
        .library(name: "RSDatePicker", targets: ["RSDatePicker"])
    ],
    targets: [
		.target(
			name: "RSDatePicker",
			path: "Files",
			resources: [
				.process("RSDatePicker.xib")
			]
		)
    ]
)
