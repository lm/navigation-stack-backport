import XCTest

final class LinkUITests: XCTestCase {
	func testNavigationLink() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-link"]
		app.launch()
		app.buttons["Link"].tap()
		XCTAssert(app.staticTexts["Link Destination"].waitForExistence(timeout: 1))
	}

	func testNavigationLinkOutsideStack() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-link-outside-stack"]
		app.launch()
		XCTAssertFalse(app.buttons["Link"].isEnabled)
	}

	func testNavigationLinkWithInvalidValue() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-link-invalid-value"]
		app.launch()
		app.buttons["Link"].tap()
		XCTAssert(app.buttons["Link"].waitForExistence(timeout: 1))
	}

	func testNavigationLinkExplicitState() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-link-explicit-state"]
		app.launch()
		app.buttons["Link"].tap()
		XCTAssert(app.staticTexts["Link Destination"].waitForExistence(timeout: 1))
	}
}
