import SwiftUI

protocol NavigationPathBox {
	var count: Int { get }
	var isEmpty: Bool { get }
	var backportedCodable: NavigationPath.CodableRepresentation? { get }

	mutating func append<V: Hashable>(_ value: V)
	mutating func append<V>(_ value: V) where V: Hashable, V: Codable
	mutating func removeLast(_ k: Int)
}

@available(iOS 16, macOS 13, *)
extension SwiftUI.NavigationPath: NavigationPathBox {
	var backportedCodable: NavigationPath.CodableRepresentation? {
		codable.map(NavigationPath.CodableRepresentation.init(storage:))
	}
}
