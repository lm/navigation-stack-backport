import SwiftUI

public struct NavigationStack<Data, Root: View>: View {
	public let body: AnyView

	public init(@ViewBuilder root: () -> Root) where Data == NavigationPath {
		if #available(iOS 16.0, *) {
			body = AnyView(SwiftUI.NavigationStack(root: root))
		} else {
			body = AnyView(ImplicitStateView(root: root()))
		}
	}

	public init(path: Binding<NavigationPath>, @ViewBuilder root: () -> Root) where Data == NavigationPath {
		if #available(iOS 16.0, *) {
			body = AnyView(SwiftUI.NavigationStack(path: path.swiftUIPath, root: root))
		} else {
			body = AnyView(AuthorityView(path: path.storage, root: root()))
		}
	}

	public init(path: Binding<Data>, @ViewBuilder root: () -> Root) where Data: MutableCollection, Data: RandomAccessCollection, Data: RangeReplaceableCollection, Data.Element: Hashable {
		if #available(iOS 16.0, *) {
			body = AnyView(SwiftUI.NavigationStack(path: path, root: root))
		} else {
			// TODO: implement special homogeneous NavigationPathBox?
			body = AnyView(AuthorityView(path: Binding {
				NavigationPathBackport(items: path.wrappedValue.map { .init(value: $0) })
			} set: {
				path.wrappedValue = .init($0.items.compactMap { $0.valueAs(Data.Element.self) })
			}, root: root()))
		}
	}
}

private extension NavigationStack {
	struct ImplicitStateView: View {
		let root: Root
		@State private var path = NavigationPathBackport(items: [])

		var body: some View {
			AuthorityView(path: $path, root: root)
		}
	}

	struct AuthorityView<Root: View>: View {
		@Binding var path: NavigationPathBackport
		let root: Root

		@StateObject private var authority = NavigationAuthority()

		var body: some View {
			UIKitNavigation(root: root.environment(\.navigationContextId, 0), path: path)
				.ignoresSafeArea()
				.environment(\.navigationAuthority, authority)
				.onPreferenceChange(DestinationIDsKey.self) { ids in
					authority.destinationIds = ids
				}
				.onPreferenceChange(PresentationIDsKey.self) { ids in
					authority.presentationIds = ids
				}
				.onReceive(authority.pathPopPublisher) { count in
					path.removeLast(path.count - count)
				}
				.onReceive(authority.pathPushPublisher) { item in
					path.items.append(item)
				}
		}
	}
}
