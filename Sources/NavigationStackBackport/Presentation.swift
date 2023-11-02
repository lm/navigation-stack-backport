import SwiftUI

public extension Backport {
	@ViewBuilder func navigationDestination<C: View>(isPresented: Binding<Bool>, @ViewBuilder destination: () -> C) -> some View {
		if #available(iOS 16.0, *) {
			content.navigationDestination(isPresented: isPresented, destination: destination)
		} else {
			content.modifier(PresentationModifier(isPresented: isPresented, destination: destination()))
		}
	}

	@ViewBuilder func navigationDestination<D: Hashable, C: View>(
		item: Binding<D?>,
		@ViewBuilder destination: @escaping (D) -> C
	) -> some View {
		if #available(iOS 17.0, *) {
			content.navigationDestination(item: item, destination: destination)
		} else {
			content.modifier(ItemPresentationModifier(item: item, destination: destination))
		}
	}
}

private struct PresentationModifier<C: View>: ViewModifier {
	@Binding var isPresented: Bool
	let destination: C

	@Namespace private var id
	@Environment(\.navigationContextId) private var contextId
	@Environment(\.navigationAuthority) private var authority

	func body(content: Content) -> some View {
		var updated = false

		content
			.transformPreference(PresentationIDsKey.self) { ids in
				ids.append(id)

				guard !updated else { return }
				updated = true
				authority.update(id: id, presentation: Presentation(contextId: contextId, isPresented: isPresented, view: destination))
			}
			.onReceive(authority.presentationPopPublisher) { id in
				guard id == self.id else { return }
				isPresented = false
			}
	}
}

private struct ItemPresentationModifier<D: Hashable, C: View>: ViewModifier {
	@Binding var item: D?
	let destination: (D) -> C

	func body(content: Content) -> some View {
		let isPresented = Binding {
			item != nil
		} set: {
			if !$0 {
				item = nil
			}
		}

		content.backport.navigationDestination(isPresented: isPresented) {
			if let item {
				destination(item)
			}
		}
	}
}

struct Presentation {
	let contextId: Int
	let isPresented: Bool
	let view: AnyView

	init(contextId: Int, isPresented: Bool, view: some View) {
		self.contextId = contextId
		self.isPresented = isPresented
		self.view = AnyView(view.environment(\.navigationContextId, contextId))
	}
}

struct PresentationIDsKey: PreferenceKey {
	static var defaultValue: [Namespace.ID] = []

	static func reduce(value: inout [Namespace.ID], nextValue: () -> [Namespace.ID]) {
		value += nextValue()
	}
}
