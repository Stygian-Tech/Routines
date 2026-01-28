//
//  Routine.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//

import Foundation
import SwiftData
import SwiftUI
import UserNotifications

@Model
/// This is the main model for the application. Routines are the basis of everything that happens in the app and are used to organize steps into logical groups to be performed at a certain time
class Routine: Identifiable {
    
    var id = UUID()
    var name: String = "New Routine"
    var time: Date = Date()
    var iconColor: String = SystemColors.blue.rawValue // Stored as a string because Color is not encodable for persistence with SwiftData
    var iconSymbol: String = "list.bullet"
    var status = RoutineCompletionStatus.incomplete
    var finishedStepCount = 0
    
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
    
    @Relationship(deleteRule: .cascade) var steps: [Step]?
    @Attribute var daysData: Data? = nil
    @Attribute var lastModifiedDate: Date?
    
    init(name: String = "New Routine", time: Date = Date(), iconColor: String = SystemColors.blue.rawValue, iconSymbol: String = "list.bullet") {
        self.name = name
        self.time = time
        self.iconColor = iconColor
        self.iconSymbol = iconSymbol
        self.lastModifiedDate = Date()
    }

    init(name: String = "New Routine", time: Date = Date(), iconColor: String = SystemColors.blue.rawValue, iconSymbol: String = "list.bullet", steps: [Step] = [Step]()) {
        self.name = name
        self.time = time
        self.iconColor = iconColor
        self.iconSymbol = iconSymbol
        self.steps = steps
        self.lastModifiedDate = Date()
    }
    
    init(name: String = "New Routine", time: Date = Date(), iconColor: String = SystemColors.blue.rawValue, iconSymbol: String = "list.bullet", days: [Weekday]) {
        self.name = name
        self.time = time
        self.iconColor = iconColor
        self.iconSymbol = iconSymbol
        self.days = days
        self.lastModifiedDate = Date()
    }
    
    // Convenience initializer for backward compatibility with string arrays (for migration)
    init(name: String = "New Routine", time: Date = Date(), iconColor: String = SystemColors.blue.rawValue, iconSymbol: String = "list.bullet", daysStrings: [String]) {
        self.name = name
        self.time = time
        self.iconColor = iconColor
        self.iconSymbol = iconSymbol
        self.days = DateUtility.weekdaysFromStrings(daysStrings)
        self.lastModifiedDate = Date()
    }
    
    
    /// Relates the `String` property `iconColor` to a `Color` from SwiftUI to be used in the interface
    ///
    /// ```swift
    /// let routine = Routine()
    ///
    /// // Code
    ///
    /// Circle().fillColor(routine.getIconColor())
    /// ```
    ///
    /// - Returns: A `Color` corresponding to the value of `iconColor`
    func getIconColor() -> Color {
        switch self.iconColor {
        case ".red":
            return Color.red
        case ".orange":
            return Color.orange
        case ".yellow":
            return Color.yellow
        case ".green":
            return Color.green
        case ".mint":
            return Color.mint
        case ".teal":
            return Color.teal
        case ".cyan":
            return Color.cyan
        case ".blue":
            return Color.blue
        case ".indigo":
            return Color.indigo
        case ".purple":
            return Color.purple
        case ".pink":
            return Color.pink
        case ".brown":
            return Color.brown
        default:
            return Color.blue
        }
    }
    
    
    /// Takes the `time` parameter and converts it to a `String` to be used in the interface
    ///
    /// ```swift
    /// let routine = Routine()
    ///
    /// // Code
    ///
    /// Text(routine.timeToString())
    /// ```
    ///
    /// - Returns: A string representation of the time
    func timeToString() -> String {
        let time = self.time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
    
    
    /// Makes a copy of the current values of a `Routine` except for the `id` and `steps`
    ///
    /// The copy method prevents variables from refencing the same `Routine`. Because `Routine` is a class, the variable just stores a pointer to the `Routine` object. This method is used when you want a separate instance of a `Routine` with the same values.
    ///
    /// ```swift
    /// let routine = Routine()
    ///
    /// // Code
    ///
    /// let routine2 = routine1.copy()
    /// ```
    /// - Returns: A new `Routine` object with the same values as `self`
    func copy() -> Routine {
        let copy = Routine(name: self.name, time: self.time, iconColor: self.iconColor, iconSymbol: self.iconSymbol, days: self.days)
        return copy
    }
    
    /// Resets all of the steps in a routine to their incomplete state
    ///
    /// This method iterates through the step list and sets `Step.isComplete` to `false` on all steps in the array. Then it generates a local notification to let the user know that the routine has been reset.
    ///
    /// ```swift
    /// let routine = Routine()
    ///
    /// // Code
    ///
    /// routine.resetSteps()
    /// ```
    func resetSteps() {
        for step in steps ?? [] {
            step.status = .incomplete
        }
        
        self.status = .incomplete
        self.finishedStepCount = 0
        
//        let content = UNMutableNotificationContent()
//        content.title = "Routine Reset"
//        content.body = "\(self.name) has been reset. Let's get started!"
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request)
    }
    
    func checkRoutineCompletion() {
        var finishedCount = 0
        var incompleteFlag = false
        var skippedFlag = false
        
        for step in steps ?? [] {
            guard step.isToday() else { continue }
            if step.status == .incomplete {
                incompleteFlag = true
            } else if step.status == .skipped {
                skippedFlag = true
                finishedCount += 1
            } else {
                finishedCount += 1
            }
        }
        
        if incompleteFlag {
            self.status = .incomplete
        } else if skippedFlag {
            self.status = .completeWithSkippedSteps
        } else {
            self.status = .complete
        }
        
        if (steps?.count ?? 0) == 0 {
            self.status = .incomplete
        }
        self.finishedStepCount = finishedCount
    }
    
    func isToday() -> Bool {
        let today = DateUtility.todayWeekday()
        return days.contains(today)
    }
    
    func skipRemainingSteps() {
        for step in steps ?? [] {
            if step.status == .incomplete && step.isToday() {
                step.status = .skipped
            }
        }
        
        self.checkRoutineCompletion()
    }
    
    func completeRemainingSteps() {
        for step in steps ?? [] {
            if step.status == .incomplete && step.isToday() {
                step.status = .complete
            }
        }
        
        self.checkRoutineCompletion()
    }
    
    /// Marks the routine as modified by updating the lastModifiedDate timestamp
    /// Call this method whenever a property is changed to track modifications
    func markAsModified() {
        self.lastModifiedDate = Date()
    }
    
    /// Ensures lastModifiedDate is initialized (for backward compatibility with existing data)
    /// Call this when loading existing routines that might not have timestamps
    func ensureTimestampInitialized() {
        if lastModifiedDate == nil {
            lastModifiedDate = Date()
        }
    }
    
}
