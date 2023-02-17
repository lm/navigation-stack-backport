import SwiftUI

struct NativeNavigation<Root: View>: ViewControllerRepresentable {
	let root: Root
	let path: NavigationPathBackport
	@Environment(\.navigationAuthority) private var authority

#if os(iOS)
	func makeUIViewController(context: Context) -> NavigationController {
		let navigationController = NavigationController()
		navigationController.navigationBar.prefersLargeTitles = true
		navigationController.navigationBar.barStyle = .default
		navigationController.navigationBar.isTranslucent = true
		authority.navigationController = navigationController
		return navigationController
	}

	func updateUIViewController(_ navigationController: NavigationController, context: Context) {
		if !navigationController.viewControllers.isEmpty, let hostingController = navigationController.viewControllers[0] as? HostingController<Root> {
			hostingController.rootView = root
		} else {
			let rootViewController = HostingController(rootView: root)
			navigationController.viewControllers = [rootViewController]
			prelayout(rootViewController: rootViewController, navigationController: navigationController)
		}

		authority.update(path: path)
	}
#else
    func makeNSViewController(context: Context) -> NavigationController {
        let navigationController = NavigationController()
        authority.navigationController = navigationController
        return navigationController
    }

    func updateNSViewController(_ navigationController: NavigationController, context: Context) {
        if !navigationController.viewControllers.isEmpty, let hostingController = navigationController.viewControllers[0] as? HostingController<Root> {
            hostingController.rootView = root
        } else {
            let rootViewController = HostingController(rootView: root)
            navigationController.setViewControllers([rootViewController], animated: false)
            prelayout(rootViewController: rootViewController, navigationController: navigationController)
        }

        authority.update(path: path)
    }
#endif
}

private extension NativeNavigation {
	func prelayout(rootViewController: HostingController<Root>, navigationController: NavigationController) {
#if os(iOS)
        navigationController.view.insertSubview(rootViewController.view, at: 0)
#else
        navigationController.view.addSubview(rootViewController.view, positioned: .below, relativeTo: nil)
#endif
        
		navigationController.addChild(rootViewController)
        
#if os(iOS)
		rootViewController.didMove(toParent: navigationController)
		navigationController.view.setNeedsLayout()
		navigationController.view.layoutIfNeeded()
#endif
	}
}
