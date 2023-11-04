@testable import NavigationStackBackport
import XCTest

final class NavigationPathTests: XCTestCase {
	struct CodableItem: Hashable, Codable {
		let x: Int
	}

	struct UncodableItem: Hashable {}

	private let encodablePath: NavigationPath = {
		var path = NavigationPath()
		path.append(1)
		path.append("foo")
		path.append(CodableItem(x: 2))
		return path
	}()

	private let encodedPath = #"["NavigationStackBackportTests.NavigationPathTests.CodableItem","{\"x\":2}","Swift.String","\"foo\"","Swift.Int","1"]"#

	override func setUpWithError() throws {
		try super.setUpWithError()

		if #available(iOS 16.0, *) {
			throw XCTSkip()
		}
	}

	func testEncode() throws {
		let data = try JSONEncoder().encode(XCTUnwrap(encodablePath.codable))
		XCTAssertEqual(encodedPath, try XCTUnwrap(String(data: data, encoding: .utf8)))
	}

	func testDecode() throws {
		let decoded = try JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: try XCTUnwrap(encodedPath.data(using: .utf8)))
		XCTAssertEqual(encodablePath, NavigationPath(decoded))
	}

	func testReencodeDecoded() throws {
		let decoded = try JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: try XCTUnwrap(encodedPath.data(using: .utf8)))
		let decodedPath = NavigationPath(decoded)
		let data = try JSONEncoder().encode(XCTUnwrap(decodedPath.codable))
		XCTAssertEqual(encodedPath, try XCTUnwrap(String(data: data, encoding: .utf8)))
	}

	func testCodableIsNilForUncodablePath() throws {
		var path = NavigationPath([1])
		XCTAssertNotNil(path.codable)
		path.append(UncodableItem())
		XCTAssertNil(path.codable)
	}
}
