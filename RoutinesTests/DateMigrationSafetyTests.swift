//
//  DateMigrationSafetyTests.swift
//  RoutinesTests
//
//  Created by AI on 12/19/24.
//

import Testing
import Foundation
@testable import Routines

/// Tests to verify that migration doesn't have side effects in getters
struct DateMigrationSafetyTests {
    
    @Test func daysGetterDoesNotModifyStoredProperty() async throws {
        // Create a routine with old string format
        let routine = Routine()
        let dayStrings = ["Monday", "Wednesday", "Friday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        routine.daysData = stringData
        
        // Store original data
        let originalData = routine.daysData
        
        // Access days property multiple times
        let _ = routine.days
        let _ = routine.days
        let _ = routine.days
        
        // Verify daysData was NOT modified by the getter
        // (It should remain as string data until explicitly migrated)
        #expect(routine.daysData == originalData)
        
        // Verify we still get correct values (migrated in memory)
        let weekdays = routine.days
        #expect(weekdays.count == 3)
    }
    
    @Test func migrateDaysIfNeededProperlyPersistsMigration() async throws {
        // Create a routine with old string format
        let routine = Routine()
        let dayStrings = ["Tuesday", "Thursday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        routine.daysData = stringData
        
        // Verify it's still in old format
        let canDecodeAsString = try? JSONDecoder().decode([String].self, from: routine.daysData!)
        #expect(canDecodeAsString != nil)
        
        // Call migration method
        routine.migrateDaysIfNeeded()
        
        // Verify data was migrated to new format
        let canDecodeAsInt = try? JSONDecoder().decode([Int].self, from: routine.daysData!)
        #expect(canDecodeAsInt != nil)
        #expect(canDecodeAsInt?.count == 2)
        
        // Verify old format no longer works
        let canStillDecodeAsString = try? JSONDecoder().decode([String].self, from: routine.daysData!)
        #expect(canStillDecodeAsString == nil)
    }
    
    @Test func stepDaysGetterDoesNotModifyStoredProperty() async throws {
        // Create a step with old string format
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine)
        let dayStrings = ["Sunday", "Saturday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        step.daysData = stringData
        
        // Store original data
        let originalData = step.daysData
        
        // Access days property multiple times
        let _ = step.days
        let _ = step.days
        let _ = step.days
        
        // Verify daysData was NOT modified by the getter
        #expect(step.daysData == originalData)
        
        // Verify we still get correct values
        let weekdays = step.days
        #expect(weekdays.count == 2)
    }
    
    @Test func stepMigrateDaysIfNeededProperlyPersistsMigration() async throws {
        // Create a step with old string format
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine)
        let dayStrings = ["Monday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        step.daysData = stringData
        
        // Call migration method
        step.migrateDaysIfNeeded()
        
        // Verify data was migrated to new format
        let canDecodeAsInt = try? JSONDecoder().decode([Int].self, from: step.daysData!)
        #expect(canDecodeAsInt != nil)
        #expect(canDecodeAsInt?.count == 1)
        #expect(canDecodeAsInt?[0] == 2) // Monday = 2
    }
    
    @Test func getterIsIdempotent() async throws {
        // Create a routine with old string format
        let routine = Routine()
        let dayStrings = ["Monday", "Friday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        routine.daysData = stringData
        
        // Access days multiple times
        let result1 = routine.days
        let result2 = routine.days
        let result3 = routine.days
        
        // Results should be consistent
        #expect(result1.count == result2.count)
        #expect(result2.count == result3.count)
        #expect(result1 == result2)
        #expect(result2 == result3)
    }
}

