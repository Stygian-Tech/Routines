//
//  EditRoutineViewTests.swift
//  RoutinesTests
//
//  Created for testing edit routine view with steps management
//

import Testing
import Foundation
import SwiftData
@testable import Routines

@MainActor
struct EditRoutineViewTests {
    
    /// Tests that steps are displayed in correct order in edit mode
    @Test func stepsDisplayInCorrectOrder() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Routine.self, Step.self, configurations: config)
        let context = container.mainContext
        
        let routine = Routine(name: "Test Routine")
        context.insert(routine)
        
        let step1 = Step(name: "Step 1", routine: routine, order: 0)
        let step2 = Step(name: "Step 2", routine: routine, order: 1)
        let step3 = Step(name: "Step 3", routine: routine, order: 2)
        
        routine.steps = [step1, step2, step3]
        try context.save()
        
        // Verify steps are sorted by order
        let sortedSteps = (routine.steps ?? []).sorted(by: { $0.order < $1.order })
        #expect(sortedSteps.count == 3)
        #expect(sortedSteps[0].name == "Step 1")
        #expect(sortedSteps[1].name == "Step 2")
        #expect(sortedSteps[2].name == "Step 3")
    }
    
    /// Tests that step reordering updates order correctly
    @Test func stepReorderingUpdatesOrder() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Routine.self, Step.self, configurations: config)
        let context = container.mainContext
        
        let routine = Routine(name: "Test Routine")
        context.insert(routine)
        
        let step1 = Step(name: "Step 1", routine: routine, order: 0)
        let step2 = Step(name: "Step 2", routine: routine, order: 1)
        let step3 = Step(name: "Step 3", routine: routine, order: 2)
        
        routine.steps = [step1, step2, step3]
        try context.save()
        
        let stepManager = StepManager(modelContext: context)
        
        // Move step at index 0 to index 2
        var indexSet = IndexSet()
        indexSet.insert(0)
        try await stepManager.moveSteps(from: indexSet, to: 3, in: routine)
        
        // Verify new order
        let sortedSteps = (routine.steps ?? []).sorted(by: { $0.order < $1.order })
        #expect(sortedSteps[0].name == "Step 2")
        #expect(sortedSteps[1].name == "Step 3")
        #expect(sortedSteps[2].name == "Step 1")
    }
    
    /// Tests that step deletion removes step and reorders remaining steps
    @Test func stepDeletionRemovesAndReorders() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Routine.self, Step.self, configurations: config)
        let context = container.mainContext
        
        let routine = Routine(name: "Test Routine")
        context.insert(routine)
        
        let step1 = Step(name: "Step 1", routine: routine, order: 0)
        let step2 = Step(name: "Step 2", routine: routine, order: 1)
        let step3 = Step(name: "Step 3", routine: routine, order: 2)
        
        routine.steps = [step1, step2, step3]
        try context.save()
        
        let stepManager = StepManager(modelContext: context)
        
        // Delete middle step
        try await stepManager.deleteSteps([step2], from: routine)
        
        // Verify step was deleted and remaining steps reordered
        let sortedSteps = (routine.steps ?? []).sorted(by: { $0.order < $1.order })
        #expect(sortedSteps.count == 2)
        #expect(sortedSteps[0].name == "Step 1")
        #expect(sortedSteps[0].order == 0)
        #expect(sortedSteps[1].name == "Step 3")
        #expect(sortedSteps[1].order == 1)
    }
    
    /// Tests that step deletion synchronizes routine days
    @Test func stepDeletionSynchronizesRoutineDays() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Routine.self, Step.self, configurations: config)
        let context = container.mainContext
        
        let routine = Routine(name: "Test Routine")
        routine.days = [.monday, .tuesday, .wednesday]
        context.insert(routine)
        
        let step1 = Step(name: "Step 1", routine: routine, order: 0, days: [.monday])
        let step2 = Step(name: "Step 2", routine: routine, order: 1, days: [.tuesday, .wednesday])
        
        routine.steps = [step1, step2]
        try context.save()
        
        let stepManager = StepManager(modelContext: context)
        let daySynchronizer = RoutineDaySynchronizer(modelContext: context)
        
        // Delete step that uses Tuesday and Wednesday
        try await stepManager.deleteSteps([step2], from: routine)
        
        // Synchronize routine days
        daySynchronizer.synchronizeRoutineDays(routine)
        try daySynchronizer.save()
        
        // Routine should now only have Monday (used by remaining step)
        #expect(routine.days.contains(.monday))
        #expect(!routine.days.contains(.tuesday))
        #expect(!routine.days.contains(.wednesday))
    }
    
    /// Tests that inline step name editing updates step name
    @Test func inlineStepNameEditingUpdatesName() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Routine.self, Step.self, configurations: config)
        let context = container.mainContext
        
        let routine = Routine(name: "Test Routine")
        context.insert(routine)
        
        let step = Step(name: "Original Name", routine: routine, order: 0)
        routine.steps = [step]
        try context.save()
        
        let stepManager = StepManager(modelContext: context)
        
        // Update step name
        try await stepManager.updateStepName(step, name: "Updated Name")
        
        #expect(step.name == "Updated Name")
    }
    
    /// Tests that all steps are shown in edit mode (not filtered by isToday)
    @Test func allStepsShownInEditMode() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Routine.self, Step.self, configurations: config)
        let context = container.mainContext
        
        let routine = Routine(name: "Test Routine")
        routine.days = [.monday, .friday] // Not today
        context.insert(routine)
        
        let step1 = Step(name: "Monday Step", routine: routine, order: 0, days: [.monday])
        let step2 = Step(name: "Friday Step", routine: routine, order: 1, days: [.friday])
        
        routine.steps = [step1, step2]
        try context.save()
        
        // In edit mode, all steps should be visible regardless of isToday()
        let sortedSteps = (routine.steps ?? []).sorted(by: { $0.order < $1.order })
        #expect(sortedSteps.count == 2)
        #expect(sortedSteps.contains(where: { $0.name == "Monday Step" }))
        #expect(sortedSteps.contains(where: { $0.name == "Friday Step" }))
    }
}

