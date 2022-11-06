import Foundation

struct NavigationPathItem {
	var isCodable: Bool { box.isCodable }
	private let box: any Box

	init<V: Hashable>(value: V) {
		box = EagerBox(value: value)
	}

	init<V: Hashable>(value: V) where V: Codable {
		box = EagerBox(value: value)
	}

	init(typeName: String, jsonValue: String) {
		box = LazyBox(typeName: typeName, jsonValue: jsonValue)
	}

	func valueAs<T>(_ type: T.Type) -> T? {
		box.valueAs(T.self)
	}

	func encodePair(container: inout UnkeyedEncodingContainer) throws {
		try box.encodePair(container: &container)
	}
}

extension NavigationPathItem: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.box.equalsTo(rhs.box)
	}
}

private protocol Box {
	var isCodable: Bool { get }
	func valueAs<T>(_ type: T.Type) -> T?
	func encodePair(container: inout UnkeyedEncodingContainer) throws
	func equalsTo(_: any Box) -> Bool
}

private struct EagerBox<Value: Hashable>: Box {
	let value: Value
	let encode: ((JSONEncoder) throws -> Data)?
	var isCodable: Bool { encode != nil }

	init(value: Value) {
		self.value = value
		encode = nil
	}

	init(value: Value) where Value: Codable {
		self.value = value
		encode = { encoder in try encoder.encode(value) }
	}

	func valueAs<T>(_ type: T.Type) -> T? {
		value as? T
	}

	func encodePair(container: inout UnkeyedEncodingContainer) throws {
		let jsonValue = String(data: try encode!(JSONEncoder()), encoding: .utf8)
		try container.encode(_typeName(type(of: value)))
		try container.encode(jsonValue)
	}

	func equalsTo(_ other: any Box) -> Bool {
		value == other.valueAs(Value.self)
	}
}

private class LazyBox: Box {
	var isCodable: Bool { true }
	private let typeName: String
	private let jsonValue: String
	private var decodedValue: Any?

	init(typeName: String, jsonValue: String) {
		self.typeName = typeName
		self.jsonValue = jsonValue
	}

	func valueAs<T>(_ type: T.Type) -> T? {
		if let decodedValue {
			return decodedValue as? T
		}

		guard let decodableType = T.self as? any Decodable.Type else { return nil }
		decodedValue = try? JSONDecoder().decode(decodableType, from: jsonValue.data(using: .utf8)!)
		return decodedValue as? T
	}

	func encodePair(container: inout UnkeyedEncodingContainer) throws {
		try container.encode(typeName)
		try container.encode(jsonValue)
	}

	func equalsTo(_ other: any Box) -> Bool {
		if let other = other as? Self {
			return typeName == other.typeName && jsonValue == other.jsonValue
		}
		return other.equalsTo(self)
	}
}
