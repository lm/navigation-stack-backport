import SwiftUI

@MainActor struct NavigationUpdate {
	var viewControllers: [ViewController] {
		didSet { changed = true }
	}

	private let navigationController: NavigationController
	private var addedViewControllers: [ViewController] = []
	private var changed = false

	init(navigationController: NavigationController) {
		self.navigationController = navigationController
		viewControllers = navigationController.viewControllers
	}

	mutating func view(_ view: AnyView, at index: Int) {
		changed = true

		if navigationController.viewControllers.indices.contains(index) {
			(navigationController.viewControllers[index] as? HostingController<AnyView>)?.rootView = view
			return
		}

		let hostingController = HostingController(rootView: view)
		viewControllers.append(hostingController)

		addedViewControllers.append(hostingController)
#if os(iOS)
		navigationController.view.insertSubview(hostingController.view, at: 0)
#else
        navigationController.view.addSubview(hostingController.view, positioned: .below, relativeTo: nil)
#endif
		navigationController.addChild(hostingController)
#if os(iOS)
		hostingController.didMove(toParent: navigationController)
#endif
	}

	func commit() {
		guard changed else { return }

		Task {
			addedViewControllers.forEach {
#if os(iOS)
                $0.willMove(toParent: nil)
#endif
				$0.view.removeFromSuperview()
				$0.removeFromParent()
			}

			if viewControllers[0].view.superview == navigationController.view {
				viewControllers[0].view.removeFromSuperview()
			}

			navigationController.setViewControllers(viewControllers, animated: true)
		}
	}
}
