import SwiftUI

public extension Backport {
	@ViewBuilder func navigationDestination<D: Hashable, C: View>(for data: D.Type, @ViewBuilder destination: @escaping (D) -> C) -> some View {
        if #available(iOS 16, macOS 13, *) {
			content.navigationDestination(for: D.self, destination: destination)
		} else {
			content.modifier(DestinationModifier(destination: destination))
		}
	}
}

private struct DestinationModifier<D: Hashable, C: View>: ViewModifier {
	let destination: (D) -> C
	@Namespace private var id
	@Environment(\.navigationAuthority) private var authority

	func body(content: Content) -> some View {
		var updated = false

		content
			.transformPreference(DestinationIDsKey.self) { ids in
				ids.insert(id)

				guard !updated else { return }
				updated = true
				authority.update(id: id, destination: Destination(view: destination))
			}
	}
}

struct Destination {
	let view: (NavigationPathItem, Int) -> AnyView?
	let accepts: (NavigationPathItem) -> Bool

	init<Data>(view: @escaping (Data) -> some View) {
		self.view = { data, contextId in
			guard let data = data.valueAs(Data.self) else { return nil }
			return AnyView(view(data).environment(\.navigationContextId, contextId))
		}
		accepts = { $0.valueAs(Data.self) != nil }
	}
}

extension EnvironmentValues {
	var navigationContextId: Int {
		get { self[ContextIdKey.self] }
		set { self[ContextIdKey.self] = newValue }
	}
}

private struct ContextIdKey: EnvironmentKey {
	static var defaultValue = 0
}

struct DestinationIDsKey: PreferenceKey {
	static var defaultValue: Set<Namespace.ID> = []

	static func reduce(value: inout Set<Namespace.ID>, nextValue: () -> Set<Namespace.ID>) {
		value = value.union(nextValue())
	}
}
