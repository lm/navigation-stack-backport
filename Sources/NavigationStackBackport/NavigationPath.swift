import SwiftUI

public struct NavigationPath {
	public var count: Int { box.count }
	public var isEmpty: Bool { box.isEmpty }
	public var codable: CodableRepresentation? { box.backportedCodable }

	private var box: any NavigationPathBox

	@available(iOS 16.0, *)
	var swiftUIPath: SwiftUI.NavigationPath {
		get { box as! SwiftUI.NavigationPath }
		set { box = newValue }
	}

	var storage: NavigationPathBackport {
		get { box as! NavigationPathBackport }
		set { box = newValue }
	}

	public init() {
		if #available(iOS 16.0, *) {
			box = SwiftUI.NavigationPath()
		} else {
			box = NavigationPathBackport(items: [])
		}
	}

	public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
		if #available(iOS 16.0, *) {
			box = SwiftUI.NavigationPath(elements)
		} else {
			box = NavigationPathBackport(items: elements.map { .init(value: $0) })
		}
	}

	public init<S: Sequence>(_ elements: S) where S.Element: Hashable, S.Element: Codable {
		if #available(iOS 16.0, *) {
			box = SwiftUI.NavigationPath(elements)
		} else {
			box = NavigationPathBackport(items: elements.map { .init(value: $0) })
		}
	}

	public init(_ codable: CodableRepresentation) {
		if #available(iOS 16.0, *) {
			box = SwiftUI.NavigationPath(codable.storage as! SwiftUI.NavigationPath.CodableRepresentation)
		} else {
			box = NavigationPathBackport(items: codable.storage as! [NavigationPathItem])
		}
	}
}

public extension NavigationPath {
	mutating func append<V: Hashable>(_ value: V) {
		box.append(value)
	}

	mutating func append<V>(_ value: V) where V: Hashable, V: Codable {
		box.append(value)
	}

	mutating func removeLast(_ k: Int = 1) {
		box.removeLast(k)
	}
}

extension NavigationPath: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		if #available(iOS 16.0, *) {
			return lhs.box as? SwiftUI.NavigationPath == rhs.box as? SwiftUI.NavigationPath
		} else {
			return lhs.box as? NavigationPathBackport == rhs.box as? NavigationPathBackport
		}
	}
}
