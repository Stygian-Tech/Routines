//
//  AppIconManagerTests.swift
//  RoutinesTests
//
//  Created by AI on 2025-08-15.
//

import XCTest
@testable import Routines

@MainActor
final class AppIconManagerTests: XCTestCase {

    func testAvailableOptionsFallbackContainsKnownIcons() {
        let manager = AppIconManager()
        // Provide empty info dictionary to force fallback path
        let options = manager.availableOptions(infoDictionary: [:])

        let names = Set(options.compactMap { $0.alternateIconName })
        XCTAssertTrue(names.contains("AppIcon-Amber"))
        XCTAssertTrue(names.contains("AppIcon-Deep"))
        XCTAssertTrue(names.contains("AppIcon-Forest"))
        XCTAssertTrue(names.contains("AppIcon-Goldenrod"))
        XCTAssertTrue(names.contains("AppIcon-Jum"))
        XCTAssertTrue(names.contains("AppIcon-Red"))
        XCTAssertTrue(names.contains("AppIcon-Teal"))

        // Primary should be present with nil alternate name
        XCTAssertTrue(options.contains(where: { $0.alternateIconName == nil }))
    }

    func testMapDisplayDerivesUserFriendlyName() {
        let manager = AppIconManager()
        let customOptions = manager.availableOptions(infoDictionary: [
            "CFBundleIcons": [
                "CFBundleAlternateIcons": [
                    "AppIcon-Goldenrod": [:],
                    "AppIcon-Teal": [:]
                ]
            ]
        ])

        let names = customOptions.map { $0.displayName }
        XCTAssertTrue(names.contains("Goldenrod"))
        XCTAssertTrue(names.contains("Teal"))
    }
}


