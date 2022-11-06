import XCTest

final class UserInteractionUITests: XCTestCase {
	func testBackTap() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-back-tap"]
		app.launch()
		app.navigationBars.buttons.firstMatch.tap()
		XCTAssert(app.staticTexts["Pushed Content 4"].waitForExistence(timeout: 1))
	}

	func testBackMenu() {
		let app = XCUIApplication()
		app.launchArguments = ["--test-back-tap"]
		app.launch()
		app.navigationBars.buttons.firstMatch.press(forDuration: 0.5)
		app.collectionViews.buttons["Root Title"].tap()
		XCTAssert(app.staticTexts["Root"].waitForExistence(timeout: 1))
	}
}
