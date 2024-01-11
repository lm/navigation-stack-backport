# SwiftUI NavigationStack Backport

`NavigationStack` for iOS 14 and 15 implemented on top of `UINavigationController`. Backport just bridges to existing SwiftUI API on iOS 16 or newer.

## Features

- `NavigationPath` is fully supported including codable representation
- `View.navigationDestination()`, `View.navigationDestination(isPresented:destination:)` and `View.navigationDestination(item:destination:)`
- `NavigationLink` with value
- for now tested only on iOS

## Getting Started

Installation via Swift Package Manager is supported. Use `https://github.com/lm/navigation-stack-backport` as depedency URL. For more information how to add dependency in Xcode see https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app or add dependency in your Package.swift `.package(url: "https://github.com/lm/navigation-stack-backport", from: "1.1.0")`

## Usage Example

Usage is the same as SwiftUI's `NavigationStack` on iOS 16, just prefix `NavigationStack` and other types with `NavigationStackBackport.` or import exact types from `NavigationStackBackport` package. For view modifiers introduced in iOS 16 use `backport.` prefix like `.backport.navigationDestination(for: …)`.

```
import NavigationStackBackport

struct ContentView: View {
	@State private var navigationPath = NavigationStackBackport.NavigationPath()

	var body: some View {
		NavigationStackBackport.NavigationStack(path: $navigationPath) {
			Button("Push") {
				navigationPath.append("Hello World")
			}
			.backport.navigationDestination(for: String.self) { value in
				Image(systemName: "globe")
					.navigationTitle(value) // use available SwiftUI's modifiers
			}
		}
	}
}

```

For more examples see the `TestApp` within this repository.
