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

	func testUpdatingPresentingDestination() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-presented-destination"]
		app.launch()
		app.buttons["Toggle Presentation"].tap()
		XCTAssert(app.staticTexts["Counter 0"].waitForExistence(timeout: 1))
		app.buttons["Inc Counter"].tap()
		XCTAssert(app.staticTexts["Counter 1"].waitForExistence(timeout: 1))
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

	func testPresentingItem() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-item-destination"]
		app.launch()
		app.buttons["Update Nested Item"].tap()
		XCTAssert(app.staticTexts["Nested Item"].waitForExistence(timeout: 1))
	}

	func testUpdatingPresentingItem() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-item-destination"]
		app.launch()
		app.buttons["Update Item"].tap()
		XCTAssert(app.staticTexts["Item 1"].waitForExistence(timeout: 1))
		app.buttons["Update Item"].tap()
		XCTAssert(app.staticTexts["Item 2"].waitForExistence(timeout: 1))
	}

	func testRootPresentingItem() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-item-destination"]
		app.launch()
		app.buttons["Update Item"].tap()
		XCTAssert(app.staticTexts["Item 1"].waitForExistence(timeout: 1))
	}

	func testRootPresentingItemOverPath() throws {
		let app = XCUIApplication()
		app.launchArguments = ["--test-item-destination"]
		app.launch()
		app.buttons["Update Item"].tap()
		XCTAssert(app.staticTexts["Item 1"].waitForExistence(timeout: 1))
		app.buttons["Back"].tap()
		XCTAssert(app.staticTexts["Root"].waitForExistence(timeout: 1))
	}

	func testItemPresentationWithinItemPresentation() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-item-destination"]
		app.launch()
		app.buttons["Update Item"].tap()
		app.buttons["Update Nested Item"].tap()
		XCTAssert(app.staticTexts["Nested Item"].waitForExistence(timeout: 1))
	}

	func testUpdatingPathWithinItemPresentation() throws {
		if #available(iOS 17.0, *) {
			if #unavailable(iOS 17.2) {
				throw XCTSkip("Causes crash on iOS 17.0, fixed in iOS 17.2")
			}
		}

		let app = XCUIApplication()
		app.launchArguments = ["--test-item-destination"]
		app.launch()
		app.buttons["Update Nested Item"].tap()
		app.buttons["Update Path"].tap()
		XCTAssert(app.staticTexts["Path Destination"].waitForExistence(timeout: 1))
	}

	func testClearingRootItemPresentation() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root-item-destination"]
		app.launch()
		app.buttons["Update Item"].tap()
		app.buttons["Update Nested Item"].tap()
		app.buttons["Clear Item"].tap()
		XCTAssert(app.staticTexts["Root"].waitForExistence(timeout: 1))
	}
}
