import XCTest

final class DestinationUITests: XCTestCase {
	func testMissingDestination() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-missing-destination"]
		app.launch()
		if #available(iOS 15.0, *) {
			XCTAssert(app.images["Warning"].waitForExistence(timeout: 1))
		} else {
			XCTAssert(app.images["warning"].waitForExistence(timeout: 1))
		}
	}

	func testConditionalDestination() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-conditional-destination"]
		app.launch()
		app.buttons["Toggle Destination"].tap()
		XCTAssert(app.staticTexts["Destination"].waitForExistence(timeout: 1))
		app.buttons["Toggle Destination"].tap()
		if #available(iOS 15.0, *) {
			XCTAssert(app.images["Warning"].waitForExistence(timeout: 1))
		} else {
			XCTAssert(app.images["warning"].waitForExistence(timeout: 1))
		}
	}

	func testPresentingDestination() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-presented-destination"]
		app.launch()
		app.buttons["Toggle Nested Presentation"].tap()
		XCTAssert(app.staticTexts["Nested Presentation"].waitForExistence(timeout: 1))
	}

	func testRootPresentingDestination() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-presented-destination"]
		app.launch()
		app.buttons["Toggle Presentation"].tap()
		XCTAssert(app.staticTexts["Presentation"].waitForExistence(timeout: 1))
	}

	func testRootPresentingDestinationOverPath() throws {
		if #available(iOS 16.1, *) {} else if #available(iOS 16.0, *) {
			throw XCTSkip("Broken in iOS 16.0, fixed in iOS 16.1")
		}

		let app = XCUIApplication()
		app.launchArguments = ["--test-presented-destination"]
		app.launch()
		app.buttons["Toggle Presentation"].tap()
		XCTAssert(app.staticTexts["Presentation"].waitForExistence(timeout: 1))
		app.buttons["Back"].tap()
		XCTAssert(app.staticTexts["Root"].waitForExistence(timeout: 1))
	}

	func testPresentationWithinPresentation() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-presented-destination"]
		app.launch()
		app.buttons["Toggle Presentation"].tap()
		app.buttons["Toggle Nested Presentation"].tap()
		XCTAssert(app.staticTexts["Nested Presentation"].waitForExistence(timeout: 1))
	}

	func testUpdatingPathWithinPresentation() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-presented-destination"]
		app.launch()
		app.buttons["Toggle Nested Presentation"].tap()
		app.buttons["Update Path"].tap()
		XCTAssert(app.staticTexts["Path Destination"].waitForExistence(timeout: 1))
	}
}
