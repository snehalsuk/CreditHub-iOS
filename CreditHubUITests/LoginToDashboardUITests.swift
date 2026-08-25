import XCTest

/// NOTE: the unlock step exercises the real biometric prompt via `LAContext`. On a Simulator this
/// requires biometrics to be enrolled first (Features > Face ID > Enrolled) and a match event sent
/// during the run (Features > Face ID > Matching Face), which is a manual step outside this test.
/// In CI, drive it with `xcrun simctl spawn booted notifyutil -p com.apple.BiometricKit_Sim.fingerTouch.match`
/// (or the Face ID equivalent) after tapping "Unlock".
final class LoginToDashboardUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_login_navigatesToDashboard() throws {
        let app = XCUIApplication()
        app.launch()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("demo@credithub.example.com")

        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["Sign In"].tap()

        let unlockButton = app.buttons["Unlock"]
        XCTAssertTrue(unlockButton.waitForExistence(timeout: 5))
        unlockButton.tap()

        let dashboardTitle = app.navigationBars["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))
    }
}
