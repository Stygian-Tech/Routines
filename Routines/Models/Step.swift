//
//  Step.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//
import Foundation
import SwiftData

    
@Model
class Step: Identifiable {
    var id = UUID()
    var name: String = "Step"
    var order: Int = 0
    var routine: Routine?
    var status = StepCompletionStatus.incomplete
    var days: [Weekday] {
        get {
            guard let data = daysData else { return DateUtility.allWeekdays() }
            
            // Try to decode as new format (array of Int)
            if let weekdayValues = try? JSONDecoder().decode([Int].self, from: data) {
                return weekdayValues.map { Weekday(rawValue: $0) }
            }
            
            // Try to decode as old format (array of String) - migration path
            // Note: We return the migrated value but don't modify daysData here
            // Migration will be persisted when days is next set, or via migrateDaysIfNeeded()
            if let dayStrings = try? JSONDecoder().decode([String].self, from: data) {
                return DateUtility.weekdaysFromStrings(dayStrings)
            }
            
            // Default: return all weekdays
            return DateUtility.allWeekdays()
        }
        set {
            let weekdayValues = newValue.map { $0.rawValue }
            daysData = try? JSONEncoder().encode(weekdayValues)
        }
    }
    
    /// Migrates days data from old string format to new weekday format if needed
    /// Call this method when you have access to ModelContext to ensure proper transaction handling
    /// - Returns: `true` if migration occurred, `false` if no migration was needed
    @discardableResult
    func migrateDaysIfNeeded() -> Bool {
        guard let data = daysData else { return false }
        
        // Check if migration is needed (old string format)
        if let dayStrings = try? JSONDecoder().decode([String].self, from: data) {
            let weekdays = DateUtility.weekdaysFromStrings(dayStrings)
            // This setter call will properly trigger SwiftData change tracking
            self.days = weekdays
            return true
        }
        
        return false
    }
    @Attribute var daysData: Data?
    @Attribute var lastModifiedDate: Date?

    init(name: String = "Step", routine: Routine?, order: Int = 0) {
        self.name = name
        self.routine = routine
        self.order = order
        self.lastModifiedDate = Date()
    }
    
    init(name: String = "Step", routine: Routine?, order: Int = 0, days: [Weekday]) {
        self.name = name
        self.routine = routine
        self.order = order
        self.days = days
        self.lastModifiedDate = Date()
    }
    
    // Convenience initializer for backward compatibility with string arrays (for migration)
    init(name: String = "Step", routine: Routine?, order: Int = 0, daysStrings: [String]) {
        self.name = name
        self.routine = routine
        self.order = order
        self.days = DateUtility.weekdaysFromStrings(daysStrings)
        self.lastModifiedDate = Date()
    }
    
    func isToday() -> Bool {
        let date = Date()
        let weekday = DateUtility.weekday(for: date)
        guard days.contains(weekday) else { return false }

        if let routine = routine {
            guard routine.days.contains(weekday) else { return false }
            return routine.isRepeatIntervalActive(on: date)
        }

        return true
    }
    
    /// Marks the step as modified by updating the lastModifiedDate timestamp
    /// Call this method whenever a property is changed to track modifications
    func markAsModified() {
        self.lastModifiedDate = Date()
    }
    
    /// Ensures lastModifiedDate is initialized (for backward compatibility with existing data)
    /// Call this when loading existing steps that might not have timestamps
    func ensureTimestampInitialized() {
        if lastModifiedDate == nil {
            lastModifiedDate = Date()
        }
    }
}
