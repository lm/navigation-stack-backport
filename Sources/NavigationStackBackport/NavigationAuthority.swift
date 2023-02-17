import Combine
import SwiftUI

class NavigationAuthority: NSObject, ObservableObject {
    
	weak var navigationController: NavigationController? {
		didSet { navigationController?.delegate = self }
	}

	var destinationIds: Set<Namespace.ID> = [] {
		didSet {
			cleanupDestinations(oldValue.subtracting(destinationIds))
		}
	}

	var presentationIds: [Namespace.ID] = [] {
		didSet {
			guard presentationIds.count < oldValue.count else { return }
			cleanupPresentations()
		}
	}

	let pathPopPublisher = PassthroughSubject<Int, Never>()
	let pathPushPublisher = PassthroughSubject<NavigationPathItem, Never>()
	let presentationPopPublisher = PassthroughSubject<Namespace.ID, Never>()
	var canNavigate: Bool { navigationController != nil }

	private var path = NavigationPathBackport(items: [])
	private var destinations: [Namespace.ID: Destination] = [:]
	private var presentations: [Namespace.ID: Presentation] = [:]
	private var viewControllersCount = 1
}

extension NavigationAuthority {
	func update(id: Namespace.ID, destination: Destination) {
		destinations[id] = destination

		guard let viewControllers = navigationController?.viewControllers else { return }

		path.items.enumerated().forEach { index, item in
			guard viewControllers.indices.contains(index + 1), let view = destination.view(item, index + 1) else { return }
            (viewControllers[index + 1] as? HostingController<AnyView>)?.rootView = view
		}
	}

	func update(id: Namespace.ID, presentation: Presentation) {
		let prevPresentation = presentations[id]
		presentations[id] = presentation

		guard let navigationController, presentation.isPresented != (prevPresentation?.isPresented ?? false) else { return }

		Task { @MainActor in
			var update = NavigationUpdate(navigationController: navigationController)
			let index = 1 + presentation.contextId + (presentationIds.lastIndex(of: id) ?? 0)
			let count = presentation.isPresented ? (index + 1) : index

			update.viewControllers = Array(update.viewControllers.prefix(count))
			if presentation.isPresented {
				update.view(presentation.view(), at: index)
			}

			update.commit()
			viewControllersCount = update.viewControllers.count

			if path.count > presentation.contextId {
				path.items = Array(path.items.prefix(presentation.contextId))
				pathPopPublisher.send(presentation.contextId)
			}
		}
	}

	@MainActor func update(path: NavigationPathBackport) {
		guard path != self.path else { return }
		self.path = path

		guard let navigationController else { return }

		var update = NavigationUpdate(navigationController: navigationController)
		update.viewControllers = Array(update.viewControllers.prefix(path.count + 1))
		path.items.enumerated().forEach { index, data in update.view(view(for: data, index: index + 1), at: index + 1) }

		update.commit()
		viewControllersCount = update.viewControllers.count
		popPresentations()
	}
}

extension NavigationAuthority: NavigationControllerDelegate {
	func navigationController(_ navigationController: NavigationController, didShow viewController: ViewController, animated: Bool) {
		let count = navigationController.viewControllers.count
		defer { viewControllersCount = count }

		guard count < viewControllersCount else { return }
		let pathCount = count - 1

		if pathCount < path.count {
			pathPopPublisher.send(pathCount)
			return
		}

		popPresentations()
	}
}

private extension NavigationAuthority {
	func view(for item: NavigationPathItem, index: Int) -> AnyView {
		for destination in destinations.values {
			if let view = destination.view(item, index) {
				return view
			}
		}

		return AnyView(Image(systemName: "exclamationmark.triangle.fill"))
	}

	func popPresentations() {
		guard let id = presentationIds.last(where: { id in presentations[id]?.isPresented ?? false }) else { return }
		presentationPopPublisher.send(id)
	}

	func cleanupDestinations(_ removedIds: Set<Namespace.ID>) {
		let removedDestinations = removedIds.map { destinations[$0] }
		destinations = destinations.filter { destinationIds.contains($0.key) }

		guard let viewControllers = navigationController?.viewControllers else { return }

		path.items.enumerated().forEach { index, item in
			guard
				removedDestinations.contains(where: { $0?.accepts(item) ?? false }),
				viewControllers.indices.contains(index + 1)
			else { return }

			(viewControllers[index + 1] as? HostingController<AnyView>)?.rootView = view(for: item, index: index + 1)
		}
	}

	func cleanupPresentations() {
		presentations = presentations.filter { presentationIds.contains($0.key) }
	}
}

extension EnvironmentValues {
	var navigationAuthority: NavigationAuthority {
		get { self[NavigationAuthorityKey.self] }
		set { self[NavigationAuthorityKey.self] = newValue }
	}
}

private struct NavigationAuthorityKey: EnvironmentKey {
	static var defaultValue = NavigationAuthority()
}
