//
//  DateMigrationHelper.swift
//  Routines
//
//  Created by AI on 12/19/24.
//

import Foundation

/// Helper for migrating day data from string arrays to weekday arrays
struct DateMigrationHelper {
    /// Migrate routine days from old string format to weekday format
    static func migrateRoutineDays(_ routine: Routine) -> [Weekday] {
        // Try to decode as new format (array of Int)
        if let data = routine.daysData,
           let weekdays = try? JSONDecoder().decode([Int].self, from: data) {
            return weekdays.map { Weekday(rawValue: $0) }
        }
        
        // Try to decode as old format (array of String)
        if let data = routine.daysData,
           let dayStrings = try? JSONDecoder().decode([String].self, from: data) {
            return DateUtility.weekdaysFromStrings(dayStrings)
        }
        
        // Default: return all weekdays
        return DateUtility.allWeekdays()
    }
    
    /// Migrate step days from old string format to weekday format
    static func migrateStepDays(_ step: Step) -> [Weekday] {
        // Try to decode as new format (array of Int)
        if let data = step.daysData,
           let weekdays = try? JSONDecoder().decode([Int].self, from: data) {
            return weekdays.map { Weekday(rawValue: $0) }
        }
        
        // Try to decode as old format (array of String)
        if let data = step.daysData,
           let dayStrings = try? JSONDecoder().decode([String].self, from: data) {
            return DateUtility.weekdaysFromStrings(dayStrings)
        }
        
        // Default: return all weekdays
        return DateUtility.allWeekdays()
    }
    
    /// Check if data needs migration (is old string format)
    static func needsMigration(_ data: Data?) -> Bool {
        guard let data = data else { return false }
        
        // Try to decode as string array (old format)
        if let _ = try? JSONDecoder().decode([String].self, from: data) {
            return true
        }
        
        return false
    }
}

