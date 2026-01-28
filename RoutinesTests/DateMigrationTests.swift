//
//  DateMigrationTests.swift
//  RoutinesTests
//
//  Created by AI on 12/19/24.
//

import Testing
import Foundation
@testable import Routines

struct DateMigrationTests {
    
    // MARK: - Routine Migration Tests
    
    @Test func migrateRoutineDaysFromStrings() async throws {
        // Create a routine with old string format
        let routine = Routine()
        let dayStrings = ["Monday", "Wednesday", "Friday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        routine.daysData = stringData
        
        // Access days property returns migrated values (getter does not persist)
        let weekdays = routine.days
        #expect(weekdays.count == 3)
        #expect(weekdays.contains(Weekday(rawValue: 2))) // Monday
        #expect(weekdays.contains(Weekday(rawValue: 4))) // Wednesday
        #expect(weekdays.contains(Weekday(rawValue: 6))) // Friday
        
        // Explicitly migrate to persist; then verify data is Int array
        _ = routine.migrateDaysIfNeeded()
        let migratedData = routine.daysData
        let migratedInts = try? JSONDecoder().decode([Int].self, from: migratedData!)
        #expect(migratedInts != nil)
        #expect(migratedInts?.count == 3)
    }
    
    @Test func migrateRoutineDaysFromInts() async throws {
        // Create a routine with new Int format
        let routine = Routine()
        let weekdayValues = [2, 4, 6] // Monday, Wednesday, Friday
        let intData = try JSONEncoder().encode(weekdayValues)
        routine.daysData = intData
        
        let weekdays = routine.days
        
        #expect(weekdays.count == 3)
        #expect(weekdays.contains(Weekday(rawValue: 2)))
        #expect(weekdays.contains(Weekday(rawValue: 4)))
        #expect(weekdays.contains(Weekday(rawValue: 6)))
    }
    
    @Test func migrateRoutineDaysEmptyData() async throws {
        // Routine with no days data should return all weekdays
        let routine = Routine()
        routine.daysData = nil
        
        let weekdays = routine.days
        
        #expect(weekdays.count == 7)
    }
    
    @Test func migrateRoutineDaysInvalidStrings() async throws {
        // Routine with invalid day strings should return all weekdays
        let routine = Routine()
        let invalidStrings = ["InvalidDay1", "InvalidDay2"]
        let stringData = try JSONEncoder().encode(invalidStrings)
        routine.daysData = stringData
        
        let weekdays = routine.days
        
        // Should default to all weekdays when no valid days found
        #expect(weekdays.count == 7)
    }
    
    // MARK: - Step Migration Tests
    
    @Test func migrateStepDaysFromStrings() async throws {
        // Create a step with old string format
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine)
        let dayStrings = ["Tuesday", "Thursday"]
        let stringData = try JSONEncoder().encode(dayStrings)
        step.daysData = stringData
        
        // Access days property returns migrated values (getter does not persist)
        let weekdays = step.days
        #expect(weekdays.count == 2)
        #expect(weekdays.contains(Weekday(rawValue: 3))) // Tuesday
        #expect(weekdays.contains(Weekday(rawValue: 5))) // Thursday
        
        // Explicitly migrate to persist; then verify data is Int array
        _ = step.migrateDaysIfNeeded()
        let migratedData = step.daysData
        let migratedInts = try? JSONDecoder().decode([Int].self, from: migratedData!)
        #expect(migratedInts != nil)
        #expect(migratedInts?.count == 2)
    }
    
    @Test func migrateStepDaysFromInts() async throws {
        // Create a step with new Int format
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine)
        let weekdayValues = [1, 7] // Sunday, Saturday
        let intData = try JSONEncoder().encode(weekdayValues)
        step.daysData = intData
        
        let weekdays = step.days
        
        #expect(weekdays.count == 2)
        #expect(weekdays.contains(Weekday(rawValue: 1)))
        #expect(weekdays.contains(Weekday(rawValue: 7)))
    }
    
    @Test func migrateStepDaysEmptyData() async throws {
        // Step with no days data should return all weekdays
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine)
        step.daysData = nil
        
        let weekdays = step.days
        
        #expect(weekdays.count == 7)
    }
    
    // MARK: - Migration Helper Tests
    
    @Test func migrateDaysIfNeededMigratesRoutineDays() async throws {
        let routine = Routine()
        let dayStrings = ["Monday", "Friday"]
        routine.days = DateUtility.weekdaysFromStrings(dayStrings)
        
        // Verify migration worked
        let weekdays = routine.days
        #expect(weekdays.count == 2)
        #expect(weekdays.contains(Weekday(rawValue: 2))) // Monday
        #expect(weekdays.contains(Weekday(rawValue: 6))) // Friday
    }
    
    @Test func migrateDaysIfNeededMigratesStepDays() async throws {
        let routine = Routine()
        let step = Step(name: "Test", routine: routine)
        let dayStrings = ["Sunday", "Saturday"]
        step.days = DateUtility.weekdaysFromStrings(dayStrings)
        
        // Verify migration worked
        let weekdays = step.days
        #expect(weekdays.count == 2)
        #expect(weekdays.contains(Weekday(rawValue: 1))) // Sunday
        #expect(weekdays.contains(Weekday(rawValue: 7))) // Saturday
    }
    
    // MARK: - Round-trip Tests
    
    @Test func roundTripMigration() async throws {
        // Set days using Weekday array
        let routine = Routine()
        let originalWeekdays = [Weekday(rawValue: 2), Weekday(rawValue: 4), Weekday(rawValue: 6)]
        routine.days = originalWeekdays
        
        // Read back
        let retrievedWeekdays = routine.days
        
        #expect(retrievedWeekdays.count == originalWeekdays.count)
        for weekday in originalWeekdays {
            #expect(retrievedWeekdays.contains(weekday))
        }
    }
}

