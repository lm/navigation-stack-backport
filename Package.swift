// swift-tools-version: 5.6
import PackageDescription

let package = Package(
	name: "navigation-stack-backport",
	platforms: [
		.iOS(.v14),
	],
	products: [
		.library(name: "NavigationStackBackport", targets: ["NavigationStackBackport"]),
	],
	targets: [
		.target(name: "NavigationStackBackport", dependencies: []),
		.testTarget(name: "NavigationStackBackportTests", dependencies: ["NavigationStackBackport"])
	]
)
