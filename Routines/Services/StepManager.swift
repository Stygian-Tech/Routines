//
//  StepManager.swift
//  Routines
//
//  Created by Sam Clemente on 11/25/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Unified business logic manager for Step operations
/// Thread-safe MainActor-isolated manager that handles all step-related operations for both iOS and watchOS
@MainActor
final class StepManager: @unchecked Sendable {
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
    
    // MARK: - CRUD Operations
    
    /// Creates a new step with the specified properties
    func createStep(
        name: String,
        routine: Routine,
        order: Int? = nil,
        days: [Weekday]? = nil
    ) async throws -> Step {
        let stepOrder = order ?? (routine.steps?.count ?? 0)
        let stepDays = days ?? routine.days
        
        let newStep = Step(
            name: name,
            routine: routine,
            order: stepOrder,
            days: stepDays
        )
        
        modelContext.insert(newStep)
        
        // Ensure steps array is initialized
        if routine.steps == nil {
            routine.steps = []
        }
        routine.steps?.append(newStep)
        
        try modelContext.save()
        triggerSyncIfNeeded()
        return newStep
    }
    
    /// Updates a step's name
    func updateStepName(_ step: Step, name: String) async throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StepManagerError.invalidName
        }
        step.name = name
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    /// Updates a step's status
    /// Note: Routine completion checking should be handled by the caller using RoutineManager
    /// to avoid circular dependencies between managers
    func updateStepStatus(_ step: Step, status: StepCompletionStatus) async throws {
        step.status = status
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    /// Cycles through step status: incomplete -> complete -> skipped -> incomplete
    func cycleStepStatus(_ step: Step) async throws {
        switch step.status {
        case .incomplete:
            step.status = .complete
        case .complete:
            step.status = .skipped
        case .skipped:
            step.status = .incomplete
        }
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    /// Updates a step's days
    func updateStepDays(_ step: Step, days: [Weekday]) async throws {
        step.days = days
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    /// Deletes one or more steps and reorders remaining steps
    func deleteSteps(_ steps: [Step], from routine: Routine) async throws {
        // Remove steps from routine's steps array
        var currentSteps = routine.steps ?? []
        for step in steps {
            if let index = currentSteps.firstIndex(where: { $0.id == step.id }) {
                currentSteps.remove(at: index)
            }
            modelContext.delete(step)
        }
        
        // Reorder remaining steps
        for (index, step) in currentSteps.enumerated() {
            step.order = index
        }
        
        routine.steps = currentSteps
        try modelContext.save()
        triggerSyncIfNeeded()
    }
    
    // MARK: - Reordering Operations
    
    /// Moves steps within a routine and updates their order
    func moveSteps(
        from source: IndexSet,
        to destination: Int,
        in routine: Routine
    ) async throws {
        var tempSteps = routine.steps ?? []
        tempSteps = tempSteps.sorted(by: { $0.order < $1.order })
        tempSteps.move(fromOffsets: source, toOffset: destination)
        
        // Update order for all steps
        for (index, step) in tempSteps.enumerated() {
            step.order = index
        }
        
        routine.steps = tempSteps
        try modelContext.save()
    }
    
    /// Reorders all steps in a routine based on their current order property
    func reorderSteps(in routine: Routine) async throws {
        guard var steps = routine.steps else { return }
        steps = steps.sorted(by: { $0.order < $1.order })
        
        for (index, step) in steps.enumerated() {
            step.order = index
        }
        
        routine.steps = steps
        try modelContext.save()
    }
    
    // MARK: - Utility Operations
    
    /// Checks if a step is scheduled for today
    func isStepToday(_ step: Step) -> Bool {
        return step.isToday()
    }
    
    /// Gets all steps for today from a routine
    /// - Throws: If migration occurs and saving fails
    func getTodaySteps(from routine: Routine) throws -> [Step] {
        // Ensure migration is done before filtering
        let routineNeedsMigration = routine.migrateDaysIfNeeded()
        var stepNeedsMigration = false
        for step in routine.steps ?? [] {
            if step.migrateDaysIfNeeded() {
                stepNeedsMigration = true
            }
        }
        
        // Save migrations if any occurred
        if routineNeedsMigration || stepNeedsMigration {
            try modelContext.save()
        }
        
        return (routine.steps ?? []).filter { $0.isToday() }.sorted { $0.order < $1.order }
    }
    
    /// Returns all days used by any step in the routine
    /// - Parameter routine: The routine to check
    /// - Returns: Set of weekdays that are used by at least one step
    func getAllDaysUsedBySteps(in routine: Routine) -> Set<Weekday> {
        guard let steps = routine.steps else { return [] }
        var allDays = Set<Weekday>()
        for step in steps {
            for day in step.days {
                allDays.insert(day)
            }
        }
        return allDays
    }
    
    /// Checks if a specific day is used by any step in the routine
    /// - Parameters:
    ///   - day: The day to check
    ///   - routine: The routine to check against
    ///   - excludingStep: Optional step to exclude from the check
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
    
    /// Saves the model context
    func save() throws {
        try modelContext.save()
    }
}

// MARK: - StepManager Errors

enum StepManagerError: LocalizedError {
    case invalidName
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Step name cannot be empty"
        }
    }
}

