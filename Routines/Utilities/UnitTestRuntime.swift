//
//  UnitTestRuntime.swift
//  Routines
//

import Foundation

/// True when the iOS app is running as the XCTest/Swift Testing host (injected test bundle).
/// Used to avoid CloudKit, push, Tips, and timers that crash or destabilize the simulator test process.
enum UnitTestRuntime {
    static var isActive: Bool { Self.isLoadedInTestHostProcess }

    private static var isLoadedInTestHostProcess: Bool {
        if NSClassFromString("XCTestCase") != nil { return true }
        let env = ProcessInfo.processInfo.environment
        if env["XCTestSessionIdentifier"] != nil { return true }
        if env["XCTestConfigurationFilePath"] != nil { return true }
        if env["XCTestBundlePath"] != nil { return true }
        if let dyld = env["DYLD_INSERT_LIBRARIES"], dyld.contains("XCTest") { return true }
        return false
    }
}
