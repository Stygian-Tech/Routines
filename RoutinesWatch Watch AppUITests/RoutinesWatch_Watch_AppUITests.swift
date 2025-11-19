//
//  RoutinesWatch_Watch_AppUITests.swift
//  RoutinesWatch Watch AppUITests
//
//  Created by Sam Clemente on 11/17/25.
//

import XCTest

final class RoutinesWatch_Watch_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    // 1. The RoutinesWatch Watch App launches successfully.
    @MainActor
    func testAppLaunchesSuccessfully() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.state, .runningForeground, "App should be running in the foreground after launch")
    }

    // 2. The ContentView displays "Hello, world!".
    @MainActor
    func testContentViewDisplaysHelloWorld() throws {
        let app = XCUIApplication()
        app.launch()
        let helloLabel = app.staticTexts["Hello, world!"]
        XCTAssertTrue(helloLabel.waitForExistence(timeout: 5), "'Hello, world!' text should be visible on launch")
    }

    // 3. All UI elements are accessible and interactive (basic checks).
    // This checks that primary elements are present and hittable where applicable.
    @MainActor
    func testUIElementsAccessibleAndInteractive() throws {
        let app = XCUIApplication()
        app.launch()

        // Validate the greeting text is accessible and hittable.
        let helloLabel = app.staticTexts["Hello, world!"]
        XCTAssertTrue(helloLabel.waitForExistence(timeout: 5), "'Hello, world!' should exist")
        XCTAssertTrue(helloLabel.isHittable, "'Hello, world!' should be hittable")

        // Validate the globe image exists and is accessible.
        let globeImage = app.images.element(boundBy: 0)
        XCTAssertTrue(globeImage.exists, "Globe image should exist")
        // Images may not always be hittable if decorative, but ensure it's there and identifiable.
        // If this fails in CI due to platform specifics, consider assigning an accessibilityIdentifier in the app code.
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
