import SwiftUI

@MainActor struct NavigationUpdate {
	var viewControllers: [UIViewController] {
		didSet { changed = true }
	}

	private let navigationController: UINavigationController
	private var addedViewControllers: [UIViewController] = []
	private var changed = false

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		viewControllers = navigationController.viewControllers
	}

	mutating func view(_ view: AnyView, at index: Int) {
		changed = true

		if navigationController.viewControllers.indices.contains(index) {
			(navigationController.viewControllers[index] as? UIHostingController<AnyView>)?.rootView = view
			return
		}

		let hostingController = UIHostingController(rootView: view)
		viewControllers.append(hostingController)

		addedViewControllers.append(hostingController)
		navigationController.view.insertSubview(hostingController.view, at: 0)
		navigationController.addChild(hostingController)
		hostingController.didMove(toParent: navigationController)
	}

	func commit() {
		guard changed else { return }

		Task {
			addedViewControllers.forEach {
				$0.willMove(toParent: nil)
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
