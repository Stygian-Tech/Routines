//
//  LocaleObserverTests.swift
//  RoutinesTests
//
//  Created by AI on 12/19/24.
//

import Testing
import Foundation
@testable import Routines

struct LocaleObserverTests {
    
    @Test func localeObserverInitializesWithCurrentSettings() async throws {
        let observer = LocaleObserver()
        
        #expect(!observer.localeIdentifier.isEmpty)
        #expect(!observer.calendarIdentifier.isEmpty)
        #expect(observer.firstWeekday >= 1)
        #expect(observer.firstWeekday <= 7)
    }
    
    @Test func localeObserverMatchesSystemSettings() async throws {
        let observer = LocaleObserver()
        
        #expect(observer.localeIdentifier == Locale.current.identifier)
        #expect(observer.calendarIdentifier == Calendar.current.identifier.rawValue)
        #expect(observer.firstWeekday == Calendar.current.firstWeekday)
    }
    
    @Test func refreshUpdatesSettings() async throws {
        let observer = LocaleObserver()
        let initialLocale = observer.localeIdentifier
        
        // Refresh should update to current system settings
        observer.refresh()
        
        #expect(observer.localeIdentifier == Locale.current.identifier)
        #expect(observer.firstWeekday == Calendar.current.firstWeekday)
    }
}

