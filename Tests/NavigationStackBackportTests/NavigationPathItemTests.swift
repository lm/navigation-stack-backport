@testable import NavigationStackBackport
import XCTest

final class NavigationPathItemTests: XCTestCase {
	func testEquals() {
		XCTAssertEqual(NavigationPathItem(value: 0), NavigationPathItem(value: 0))
		XCTAssertEqual(NavigationPathItem(value: 0), NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0"))
		XCTAssertEqual(NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0"), NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0"))
		XCTAssertEqual(NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0"), NavigationPathItem(value: 0))
	}

	func testValueAs() {
		XCTAssertEqual(0, NavigationPathItem(value: 0).valueAs(Int.self))
		XCTAssertNil(NavigationPathItem(value: 0).valueAs(String.self))
		XCTAssertEqual(0, NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0").valueAs(Int.self))
		XCTAssertNil(NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0").valueAs(String.self))
	}

	func testIsCodable() {
		struct NonCodable: Hashable {}
		XCTAssert(NavigationPathItem(value: 0).isCodable)
		XCTAssertFalse(NavigationPathItem(value: NonCodable()).isCodable)
		XCTAssert(NavigationPathItem(typeName: _typeName(Int.self), jsonValue: "0").isCodable)
	}
}
