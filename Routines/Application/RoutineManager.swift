//
//  RoutineManager.swift
//  Routines
//
//  Created by Sam Clemente on 11/25/25.
//

import Foundation
import SwiftData

/// Unified business logic manager for Routine operations
/// Thread-safe MainActor-isolated manager that handles all routine-related operations for both iOS and watchOS
@MainActor
final class RoutineManager: @unchecked Sendable {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Reset Operations
    
    /// Resets all steps in the given routines to incomplete state
    func resetRoutines(_ routines: [Routine]) async throws {
        for routine in routines {
            try await resetRoutine(routine)
        }
        try modelContext.save()
    }
    
    /// Resets all steps in a single routine to incomplete state
    func resetRoutine(_ routine: Routine) async throws {
        for step in routine.steps ?? [] {
            step.status = .incomplete
        }
        routine.status = .incomplete
        routine.finishedStepCount = 0
    }
    
    // MARK: - Completion Checking
    
    /// Checks and updates the completion status of a routine based on its steps
    func checkRoutineCompletion(_ routine: Routine) async {
        var finishedCount = 0
        var incompleteFlag = false
        var skippedFlag = false
        
        for step in routine.steps ?? [] {
            guard step.isToday() else { continue }
            
            switch step.status {
            case .incomplete:
                incompleteFlag = true
            case .skipped:
                skippedFlag = true
                finishedCount += 1
            case .complete:
                finishedCount += 1
            }
        }
        
        // Determine routine status
        if incompleteFlag {
            routine.status = .incomplete
        } else if skippedFlag {
            routine.status = .completeWithSkippedSteps
        } else {
            routine.status = .complete
        }
        
        // If no steps, mark as incomplete
        if (routine.steps?.count ?? 0) == 0 {
            routine.status = .incomplete
        }
        
        routine.finishedStepCount = finishedCount
    }
    
    /// Checks completion status for multiple routines
    func checkRoutinesCompletion(_ routines: [Routine]) async {
        for routine in routines {
            await checkRoutineCompletion(routine)
        }
    }
    
    // MARK: - Bulk Step Operations
    
    /// Skips all remaining incomplete steps for today in a routine
    func skipRemainingSteps(_ routine: Routine) async throws {
        for step in routine.steps ?? [] {
            if step.status == .incomplete && step.isToday() {
                step.status = .skipped
            }
        }
        await checkRoutineCompletion(routine)
        try modelContext.save()
    }
    
    /// Completes all remaining incomplete steps for today in a routine
    func completeRemainingSteps(_ routine: Routine) async throws {
        for step in routine.steps ?? [] {
            if step.status == .incomplete && step.isToday() {
                step.status = .complete
            }
        }
        await checkRoutineCompletion(routine)
        try modelContext.save()
    }
    
    // MARK: - CRUD Operations
    
    /// Creates a new routine with the specified properties
    func createRoutine(
        name: String,
        time: Date,
        iconColor: String,
        iconSymbol: String,
        days: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    ) async throws -> Routine {
        let routine = Routine(
            name: name,
            time: time,
            iconColor: iconColor,
            iconSymbol: iconSymbol,
            days: days
        )
        modelContext.insert(routine)
        try modelContext.save()
        return routine
    }
    
    /// Updates an existing routine's properties
    func updateRoutine(
        _ routine: Routine,
        name: String? = nil,
        time: Date? = nil,
        iconColor: String? = nil,
        iconSymbol: String? = nil,
        days: [String]? = nil
    ) async throws {
        if let name = name {
            routine.name = name
        }
        if let time = time {
            routine.time = time
        }
        if let iconColor = iconColor {
            routine.iconColor = iconColor
        }
        if let iconSymbol = iconSymbol {
            routine.iconSymbol = iconSymbol
        }
        if let days = days {
            routine.days = days
        }
        try modelContext.save()
    }
    
    /// Deletes one or more routines
    func deleteRoutines(_ routines: [Routine]) async throws {
        for routine in routines {
            modelContext.delete(routine)
        }
        try modelContext.save()
    }
    
    // MARK: - Utility Operations
    
    /// Checks if a routine is scheduled for today
    func isRoutineToday(_ routine: Routine) -> Bool {
        return routine.isToday()
    }
    
    /// Fetches routines scheduled for today, sorted by time
    func getTodayRoutines() async throws -> [Routine] {
        let descriptor = FetchDescriptor<Routine>(
            sortBy: [SortDescriptor(\Routine.time, order: .forward)]
        )
        let allRoutines = try modelContext.fetch(descriptor)
        return allRoutines.filter { $0.isToday() }
    }
    
    /// Saves the model context
    func save() async throws {
        try modelContext.save()
    }
}

