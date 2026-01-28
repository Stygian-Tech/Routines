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
    private weak var syncObserver: CloudKitSyncObserver?
    
    init(modelContext: ModelContext, syncObserver: CloudKitSyncObserver? = nil) {
        self.modelContext = modelContext
        self.syncObserver = syncObserver
    }
    
    /// Helper to trigger sync after critical saves
    /// Waits a short time to allow CloudKit to process the save before syncing
    private func triggerSyncIfNeeded() {
        Task { @MainActor [weak self] in
            // Wait a moment for CloudKit to process the save
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await self?.syncObserver?.fetchChanges()
        }
    }
    
    // MARK: - Reset Operations
    
    /// Resets all steps in the given routines to incomplete state
    func resetRoutines(_ routines: [Routine]) async throws {
        for routine in routines {
            try await resetRoutine(routine)
        }
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    /// Resets all steps in a single routine to incomplete state
    func resetRoutine(_ routine: Routine) async throws {
        for step in routine.steps ?? [] {
            step.status = .incomplete
        }
        routine.status = .incomplete
        routine.finishedStepCount = 0
        // Note: Sync will be triggered by resetRoutines which calls save()
    }
    
    // MARK: - Completion Checking
    
    /// Checks and updates the completion status of a routine based on its steps
    func checkRoutineCompletion(_ routine: Routine) async throws {
        // Ensure migration is done before checking completion
        let needsMigration = routine.migrateDaysIfNeeded()
        var stepNeedsMigration = false
        for step in routine.steps ?? [] {
            if step.migrateDaysIfNeeded() {
                stepNeedsMigration = true
            }
        }
        
        // Save migrations if any occurred
        if needsMigration || stepNeedsMigration {
            try modelContext.save()
        }
        
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
        // Note: Don't trigger sync here as this is often called after step updates
        // Sync will be triggered by the step update that caused this check
    }
    
    /// Checks completion status for multiple routines
    func checkRoutinesCompletion(_ routines: [Routine]) async throws {
        for routine in routines {
            try await checkRoutineCompletion(routine)
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
        try await checkRoutineCompletion(routine)
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    /// Completes all remaining incomplete steps for today in a routine
    func completeRemainingSteps(_ routine: Routine) async throws {
        for step in routine.steps ?? [] {
            if step.status == .incomplete && step.isToday() {
                step.status = .complete
            }
        }
        try await checkRoutineCompletion(routine)
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    // MARK: - CRUD Operations
    
    /// Creates a new routine with the specified properties
    func createRoutine(
        name: String,
        time: Date,
        iconColor: String,
        iconSymbol: String,
        days: [Weekday]? = nil
    ) async throws -> Routine {
        let routineDays = days ?? DateUtility.allWeekdays()
        let routine = Routine(
            name: name,
            time: time,
            iconColor: iconColor,
            iconSymbol: iconSymbol,
            days: routineDays
        )
        modelContext.insert(routine)
        try modelContext.save()
        triggerSyncIfNeeded()
        return routine
    }
    
    /// Updates an existing routine's properties
    func updateRoutine(
        _ routine: Routine,
        name: String? = nil,
        time: Date? = nil,
        iconColor: String? = nil,
        iconSymbol: String? = nil,
        days: [Weekday]? = nil
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
        triggerSyncIfNeeded()
    }
    
    /// Deletes one or more routines
    func deleteRoutines(_ routines: [Routine]) async throws {
        for routine in routines {
            modelContext.delete(routine)
        }
        try modelContext.save()
        triggerSyncIfNeeded()
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
        
        // Migrate days data if needed (lazy migration on access)
        for routine in allRoutines {
            routine.migrateDaysIfNeeded()
            // Also migrate steps
            for step in routine.steps ?? [] {
                step.migrateDaysIfNeeded()
            }
        }
        
        // Save any migrations that occurred
        try modelContext.save()
        
        return allRoutines.filter { $0.isToday() }
    }
    
    /// Fetches all routines, sorted by time
    func getAllRoutines() async throws -> [Routine] {
        let descriptor = FetchDescriptor<Routine>(
            sortBy: [SortDescriptor(\Routine.time, order: .forward)]
        )
        let allRoutines = try modelContext.fetch(descriptor)
        
        // Migrate days data if needed (lazy migration on access)
        for routine in allRoutines {
            routine.migrateDaysIfNeeded()
            // Also migrate steps
            for step in routine.steps ?? [] {
                step.migrateDaysIfNeeded()
            }
        }
        
        // Save any migrations that occurred
        try modelContext.save()
        
        return allRoutines
    }
    
    /// Saves the model context
    func save() async throws {
        try modelContext.save()
    }
}

