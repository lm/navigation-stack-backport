import struct NavigationStackBackport.NavigationStack
import struct NavigationStackBackport.NavigationPath
import struct NavigationStackBackport.NavigationLink
import SwiftUI

@main
struct TestAppApp: App {
	let testName = ProcessInfo.processInfo.arguments[1]

	var body: some Scene {
		WindowGroup {
			switch testName {
			case "--test-root":
				RootTestView()
			case "--test-push":
				PushTestView()
			case "--test-pop":
				PopTestView()
			case "--test-push-many":
				PushManyTestView()
			case "--test-pop-many":
				PopManyTestView()
			case "--test-missing-destination":
				MissingDestinationTestView()
			case "--test-conditional-destination":
				ConditionalDestinationTestView()
			case "--test-back-tap":
				BackTapTestView()
			case "--test-presented-destination":
				PresentedDestinationTestView(path: [1, 2])
			case "--test-root-presented-destination":
				PresentedDestinationTestView(path: [])
			case "--test-link":
				NavigationLinkTestView()
			case "--test-link-outside-stack":
				NavigationLinkOutsideStackTestView()
			case "--test-link-invalid-value":
				NavigationLinkWithInvalidValueTestView()
			case "--test-link-explicit-state":
				NavigationLinkExplicitStateTestView()
			default:
				fatalError()
			}
		}
	}
}

struct RootTestView: View {
	var body: some View {
		NavigationStack {
			Text("Root Content")
				.navigationTitle("Root Title")
		}
	}
}

struct PushTestView: View {
	@State private var path = NavigationPath()

	var body: some View {
		NavigationStack(path: $path) {
			Button("Push") { path.append(0) }
				.navigationTitle("Root Title")
				.backport.navigationDestination(for: Int.self) { _ in
					Text("Pushed Content")
						.navigationTitle("Pushed Title")
				}
		}
	}
}

struct PopTestView: View {
	@State private var path = NavigationPath([0])

	var body: some View {
		NavigationStack(path: $path) {
			Text("\(path.count)")
				.backport.navigationDestination(for: Int.self) { _ in }
		}
	}
}

struct PushManyTestView: View {
	@State private var path = NavigationPath()

	var body: some View {
		NavigationStack(path: $path) {
			Button("Push") { path = NavigationPath(Array(0...10)) }
				.backport.navigationDestination(for: Int.self) { i in
					Text("\(i)")
				}
		}
	}
}

struct PopManyTestView: View {
	@State private var path = NavigationPath()

	var body: some View {
		NavigationStack(path: $path) {
			Button("Push") { path = NavigationPath(Array(0...10)) }
				.backport.navigationDestination(for: Int.self) { i in
					Button("Pop") { path = NavigationPath() }
				}
		}
	}
}

struct MissingDestinationTestView: View {
	@State private var path = NavigationPath([0])

	var body: some View {
		NavigationStack(path: $path) {
			Text("Root")
		}
	}
}

struct ConditionalDestinationTestView: View {
	@State private var path = NavigationPath([0])
	@State private var enableDestination = false

	var body: some View {
		NavigationStack(path: $path) {
			if enableDestination {
				Text("\(String(describing: enableDestination))")
					.backport.navigationDestination(for: Int.self) { i in
						Text("Destination")
					}

			} else {
				Text("Root")
			}
		}
		.overlay(Button("Toggle Destination") { enableDestination.toggle() })
	}
}

struct BackTapTestView: View {
	@State private var path = NavigationPath(Array(0...5))

	var body: some View {
		NavigationStack(path: $path) {
			Text("Root")
				.backport.navigationDestination(for: Int.self) { i in
					Text("Pushed Content \(i)")
						.navigationTitle("Pushed Title")
				}
				.navigationTitle("Root Title")
		}
	}
}

struct PresentedDestinationTestView: View {
	@State var path: [Int]
	@State private var isPresented = false

	var body: some View {
		NavigationStack(path: $path) {
			Text("Root")
				.backport.navigationDestination(for: Int.self) { i in
					VStack {
						Text("Path Destination")
						PresentationView()
					}
				}
				.backport.navigationDestination(isPresented: $isPresented) {
					VStack {
						Text("Presentation")
						PresentationView()
					}
				}
		}
		.overlay(VStack {
			Button("Toggle Presentation") { isPresented.toggle() }
			Button("Update Path") { path[0] += 1 }
		}, alignment: .bottom)
	}

	struct PresentationView: View {
		@State private var isPresented = false

		var body: some View {
			Button("Toggle Nested Presentation") {
				isPresented.toggle()
			}
			.backport.navigationDestination(isPresented: $isPresented) {
				Text("Nested Presentation")
			}
		}
	}
}

struct NavigationLinkTestView: View {
	var body: some View {
		NavigationStack {
			NavigationLink("Link", value: 0)
				.backport.navigationDestination(for: Int.self) { i in
					Text("Link Destination")
				}
		}
	}
}

struct NavigationLinkOutsideStackTestView: View {
	var body: some View {
		NavigationLink("Link", value: 0)
	}
}

struct NavigationLinkWithInvalidValueTestView: View {
	@State private var path: [Int] = []

	var body: some View {
		NavigationStack(path: $path) {
			NavigationLink("Link", value: "0")
		}
	}
}

struct NavigationLinkExplicitStateTestView: View {
	@State private var path = NavigationPath()

	var body: some View {
		NavigationStack(path: $path) {
			NavigationLink("Link", value: 0)
				.backport.navigationDestination(for: Int.self) { i in
					Text("Link Destination")
				}
		}
	}
}
