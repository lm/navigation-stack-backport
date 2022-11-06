import SwiftUI

struct UIKitNavigation<Root: View>: UIViewControllerRepresentable {
	let root: Root
	let path: NavigationPathBackport
	@Environment(\.navigationAuthority) private var authority

	func makeUIViewController(context: Context) -> UINavigationController {
		let navigationController = UINavigationController()
		navigationController.navigationBar.prefersLargeTitles = true
		navigationController.navigationBar.barStyle = .default
		navigationController.navigationBar.isTranslucent = true
		authority.navigationController = navigationController
		return navigationController
	}

	func updateUIViewController(_ navigationController: UINavigationController, context: Context) {
		if !navigationController.viewControllers.isEmpty, let hostingController = navigationController.viewControllers[0] as? UIHostingController<Root> {
			hostingController.rootView = root
		} else {
			let rootViewController = UIHostingController(rootView: root)
			navigationController.viewControllers = [rootViewController]
			prelayout(rootViewController: rootViewController, navigationController: navigationController)
		}

		authority.update(path: path)
	}
}

private extension UIKitNavigation {
	func prelayout(rootViewController: UIHostingController<Root>, navigationController: UINavigationController) {
		navigationController.view.insertSubview(rootViewController.view, at: 0)
		navigationController.addChild(rootViewController)
		rootViewController.didMove(toParent: navigationController)

		navigationController.view.setNeedsLayout()
		navigationController.view.layoutIfNeeded()
	}
}
