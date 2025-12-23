//
//  RoutineDaySynchronizer.swift
//  Routines
//
//  Created for routine-step day synchronization
//

import Foundation
import SwiftData

/// Handles synchronization of days between routines and their steps.
/// 
/// This utility ensures that:
/// - Routine days are always the superset of all step days
/// - When a step adds a day not in the routine, the routine expands
/// - When a step removes a day and no other step uses it, the routine shrinks
/// - When a routine removes a day that a step uses, the removal is prevented
@MainActor
final class RoutineDaySynchronizer {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Day Computation
    
    /// Computes the union of all days used by any step in the routine
    /// - Parameter routine: The routine to compute days for
    /// - Returns: Array of weekdays that are used by at least one step
    func computeRequiredDays(for routine: Routine) -> [Weekday] {
        guard let steps = routine.steps, !steps.isEmpty else {
            return []
        }
        
        var allDays = Set<Weekday>()
        for step in steps {
            for day in step.days {
                allDays.insert(day)
            }
        }
        
        return allDays.sorted()
    }
    
    /// Checks if a specific day is used by any step in the routine
    /// - Parameters:
    ///   - day: The day to check
    ///   - routine: The routine to check against
    ///   - excludingStep: Optional step to exclude from the check (useful when removing a day from a step)
    /// - Returns: True if any step (excluding the specified one) uses this day
    func isDayUsedByAnyStep(_ day: Weekday, in routine: Routine, excludingStep: Step? = nil) -> Bool {
        guard let steps = routine.steps else { return false }
        
        for step in steps {
            if let excludedStep = excludingStep, step.id == excludedStep.id {
                continue
            }
            if step.days.contains(day) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Synchronization Operations
    
    /// Synchronizes routine days to be the superset of all step days
    /// Call this after bulk step changes to ensure routine covers all steps
    /// - Parameter routine: The routine to synchronize
    func synchronizeRoutineDays(_ routine: Routine) {
        let requiredDays = computeRequiredDays(for: routine)
        
        // Start with current routine days
        var newDays = Set(routine.days)
        
        // Add any days required by steps that aren't in routine
        for day in requiredDays {
            newDays.insert(day)
        }
        
        // Remove days that no step uses (shrink routine)
        for day in routine.days {
            if !requiredDays.contains(day) {
                newDays.remove(day)
            }
        }
        
        // Only update if changed
        let sortedNewDays = newDays.sorted()
        if sortedNewDays != routine.days.sorted() {
            routine.days = sortedNewDays
        }
    }
    
    /// Adds a day to a step and expands the routine if needed
    /// - Parameters:
    ///   - step: The step to add the day to
    ///   - day: The day to add
    ///   - routine: The parent routine (will be expanded if day is not already included)
    func addDayToStep(_ step: Step, day: Weekday, routine: Routine) {
        // Add day to step if not already present
        if !step.days.contains(day) {
            var stepDays = step.days
            stepDays.append(day)
            step.days = stepDays.sorted()
        }
        
        // Expand routine if this day isn't in routine
        if !routine.days.contains(day) {
            var routineDays = routine.days
            routineDays.append(day)
            routine.days = routineDays.sorted()
        }
    }
    
    /// Removes a day from a step and shrinks the routine if no other step uses it
    /// - Parameters:
    ///   - step: The step to remove the day from
    ///   - day: The day to remove
    ///   - routine: The parent routine (will be shrunk if no other step uses this day)
    func removeDayFromStep(_ step: Step, day: Weekday, routine: Routine) {
        // Remove day from step
        var stepDays = step.days
        stepDays.removeAll { $0 == day }
        step.days = stepDays
        
        // Check if any other step uses this day
        if !isDayUsedByAnyStep(day, in: routine, excludingStep: step) {
            // No other step uses this day, shrink routine
            var routineDays = routine.days
            routineDays.removeAll { $0 == day }
            routine.days = routineDays
        }
    }
    
    /// Toggles a day for a step with proper routine synchronization
    /// - Parameters:
    ///   - step: The step to toggle the day for
    ///   - day: The day to toggle
    ///   - routine: The parent routine
    func toggleDayForStep(_ step: Step, day: Weekday, routine: Routine) {
        if step.days.contains(day) {
            removeDayFromStep(step, day: day, routine: routine)
        } else {
            addDayToStep(step, day: day, routine: routine)
        }
    }
    
    /// Checks if removing a day would leave any step with zero days
    /// - Parameters:
    ///   - day: The day to check
    ///   - routine: The routine to check against
    /// - Returns: True if removing this day would orphan at least one step
    func wouldOrphanAnyStep(_ day: Weekday, in routine: Routine) -> Bool {
        guard let steps = routine.steps else { return false }
        
        for step in steps {
            // If this step only has this one day, removing it would orphan the step
            if step.days.count == 1 && step.days.contains(day) {
                return true
            }
        }
        
        return false
    }
    
    /// Returns the set of days that cannot be removed from the routine because
    /// at least one step has only that day scheduled
    /// - Parameter routine: The routine to check
    /// - Returns: Set of days that would orphan a step if removed
    func getDaysThatWouldOrphanSteps(in routine: Routine) -> Set<Weekday> {
        guard let steps = routine.steps else { return [] }
        
        var lockedDays = Set<Weekday>()
        for step in steps {
            // If step has only one day, that day is locked
            if step.days.count == 1, let onlyDay = step.days.first {
                lockedDays.insert(onlyDay)
            }
        }
        
        return lockedDays
    }
    
    /// Removes a day from routine and cascades to all steps
    /// - Parameters:
    ///   - day: The day to remove
    ///   - routine: The routine to remove the day from
    /// - Returns: True if the day was removed, false if it would orphan a step
    @discardableResult
    func cascadeRemoveDayFromRoutine(_ day: Weekday, routine: Routine) -> Bool {
        // Don't allow removal if it would leave any step with zero days
        if wouldOrphanAnyStep(day, in: routine) {
            return false
        }
        
        // Remove day from routine
        var routineDays = routine.days
        routineDays.removeAll { $0 == day }
        routine.days = routineDays
        
        // Cascade removal to all steps that have this day
        if let steps = routine.steps {
            for step in steps {
                if step.days.contains(day) {
                    var stepDays = step.days
                    stepDays.removeAll { $0 == day }
                    step.days = stepDays
                }
            }
        }
        
        return true
    }
    
    /// Checks if removing a day from routine is allowed (wouldn't orphan any step)
    /// - Parameters:
    ///   - day: The day to check
    ///   - routine: The routine to check against
    /// - Returns: True if the day can be safely removed from the routine
    func canRemoveDayFromRoutine(_ day: Weekday, routine: Routine) -> Bool {
        return !wouldOrphanAnyStep(day, in: routine)
    }
    
    /// Toggles a day for a routine with cascade behavior
    /// - Parameters:
    ///   - day: The day to toggle
    ///   - routine: The routine to toggle the day for
    /// - Returns: True if the toggle was successful, false if removal would orphan a step
    @discardableResult
    func toggleDayForRoutine(_ day: Weekday, routine: Routine) -> Bool {
        if routine.days.contains(day) {
            return cascadeRemoveDayFromRoutine(day, routine: routine)
        } else {
            // Adding is always allowed
            var routineDays = routine.days
            routineDays.append(day)
            routine.days = routineDays.sorted()
            return true
        }
    }
    
    /// Saves the model context
    func save() throws {
        try modelContext.save()
    }
}
