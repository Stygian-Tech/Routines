//
//  RoutinesUITests.swift
//  RoutinesUITests
//
//  Created by Sam Clemente on 6/30/24.
//

import XCTest

final class RoutinesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testFlows_coverPrimaryUI() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UI_TEST_SEED")
        app.launch()

        // Toggle show all routines (if present)
        let showAllButton = app.navigationBars.buttons.matching(identifier: "Show All Routines").firstMatch
        if showAllButton.exists { showAllButton.tap() }

        // Open Settings
        let gear = app.navigationBars.buttons.matching(identifier: "Donate").firstMatch
        if gear.exists { gear.tap() }
        let done = app.navigationBars.buttons["Done"]
        if done.waitForExistence(timeout: 2) { done.tap() }

        // Add Routine flow
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        if addButton.exists { addButton.tap() }
        let cancel = app.navigationBars.buttons["Cancel"]
        if cancel.waitForExistence(timeout: 2) { cancel.tap() }

        // Navigate to first routine cell
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 2) { firstCell.tap() }

        // Toggle hidden steps and open add step sheet
        let navBarButton = app.navigationBars.buttons.element(boundBy: 0)
        if navBarButton.exists { navBarButton.tap() }
        let fab = app.buttons.matching(identifier: "plus").firstMatch
        if fab.exists { fab.tap() }
        let cancelAddStep = app.navigationBars.buttons["Cancel"]
        if cancelAddStep.waitForExistence(timeout: 2) { cancelAddStep.tap() }

        // Back to list
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
