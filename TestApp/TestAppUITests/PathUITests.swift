import XCTest

final class PathUITests: XCTestCase {
	func testRoot() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-root"]
		app.launch()
		XCTAssert(app.staticTexts["Root Title"].waitForExistence(timeout: 1))
		XCTAssert(app.staticTexts["Root Content"].waitForExistence(timeout: 1))
	}

	func testPush() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-push"]
		app.launch()
		app.buttons["Push"].tap()
		XCTAssert(app.staticTexts["Pushed Title"].waitForExistence(timeout: 1))
		XCTAssert(app.staticTexts["Pushed Content"].waitForExistence(timeout: 1))
	}

	func testPop() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-pop"]
		app.launch()
		app.buttons["Back"].tap()
		XCTAssert(app.staticTexts["0"].waitForExistence(timeout: 1))
	}

	func testPushMany() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-push-many"]
		app.launch()
		app.buttons["Push"].tap()
		XCTAssert(app.staticTexts["10"].waitForExistence(timeout: 1))
	}

	func testPopMany() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-pop-many"]
		app.launch()
		app.buttons["Push"].tap()
		_ = app.buttons["Pop"].waitForExistence(timeout: 1)
		app.buttons["Pop"].tap()
		XCTAssert(app.buttons["Push"].waitForExistence(timeout: 1))
	}
}
