struct NavigationPathBackport {
	var items: [NavigationPathItem]
}

extension NavigationPathBackport: Equatable {}

extension NavigationPathBackport: NavigationPathBox {
	var count: Int { items.count }
	var isEmpty: Bool { items.isEmpty }

	var backportedCodable: NavigationPath.CodableRepresentation? {
		guard items.allSatisfy(\.isCodable) else { return nil }
		return .init(storage: items)
	}

	mutating func append<V: Hashable>(_ value: V) {
		items.append(NavigationPathItem(value: value))
	}

	mutating func append<V>(_ value: V) where V: Hashable, V: Codable {
		items.append(NavigationPathItem(value: value))
	}

	mutating func removeLast(_ k: Int) {
		items.removeLast(k)
	}
}
