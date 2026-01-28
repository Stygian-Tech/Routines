//
//  WatchOSFunctionalityTests.swift
//  RoutinesTests
//
//  Created for testing watchOS-specific functionality
//

import Testing
import Foundation
@testable import Routines

/// Tests for watchOS-specific functionality including step status cycling and routine/step creation
struct WatchOSFunctionalityTests {
    
    /// Tests that step status cycles correctly: incomplete -> complete -> skipped -> incomplete
    @Test func stepStatusCycling() async throws {
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine, order: 0)
        
        // Start incomplete
        #expect(step.status == .incomplete)
        
        // Cycle to complete
        step.status = .complete
        #expect(step.status == .complete)
        
        // Cycle to skipped
        step.status = .skipped
        #expect(step.status == .skipped)
        
        // Cycle back to incomplete
        step.status = .incomplete
        #expect(step.status == .incomplete)
    }
    
    /// Tests that routine completion status updates correctly when steps are completed
    @Test func routineCompletionStatusUpdates() async throws {
        let routine = Routine(name: "Test Routine")
        let step1 = Step(name: "Step 1", routine: routine, order: 0)
        let step2 = Step(name: "Step 2", routine: routine, order: 1)
        
        routine.steps = [step1, step2]
        
        // Initially incomplete
        routine.checkRoutineCompletion()
        #expect(routine.status == .incomplete)
        
        // Complete all steps
        step1.status = .complete
        step2.status = .complete
        routine.checkRoutineCompletion()
        #expect(routine.status == .complete)
        
        // Skip one step
        step1.status = .skipped
        step2.status = .complete
        routine.checkRoutineCompletion()
        #expect(routine.status == .completeWithSkippedSteps)
        
        // Reset steps
        routine.resetSteps()
        #expect(step1.status == .incomplete)
        #expect(step2.status == .incomplete)
        #expect(routine.status == .incomplete)
    }
    
    /// Tests that steps can be added to a routine with correct ordering
    @Test func addingStepsToRoutine() async throws {
        let routine = Routine(name: "Test Routine")
        routine.steps = []
        
        // Add first step
        let step1 = Step(name: "First Step", routine: routine, order: 0)
        routine.steps?.append(step1)
        #expect((routine.steps ?? []).count == 1)
        #expect(routine.steps?[0].order == 0)
        
        // Add second step
        let step2 = Step(name: "Second Step", routine: routine, order: 1)
        routine.steps?.append(step2)
        #expect((routine.steps ?? []).count == 2)
        #expect(routine.steps?[1].order == 1)
        
        // Verify steps are in correct order
        let sortedSteps = (routine.steps ?? []).sorted { $0.order < $1.order }
        #expect(sortedSteps[0].name == "First Step")
        #expect(sortedSteps[1].name == "Second Step")
    }
    
    /// Tests that routine creation with all properties works correctly
    @Test func routineCreationWithAllProperties() async throws {
        let time = makeTime(hour: 9, minute: 30)
        let routine = Routine(
            name: "Morning Routine",
            time: time,
            iconColor: SystemColors.purple.rawValue,
            iconSymbol: "sun.and.horizon"
        )
        
        #expect(routine.name == "Morning Routine")
        #expect(routine.time == time)
        #expect(routine.iconColor == SystemColors.purple.rawValue)
        #expect(routine.iconSymbol == "sun.and.horizon")
        #expect((routine.steps ?? []).isEmpty)
    }
    
    /// Tests that step filtering by today works correctly
    @Test func stepFilteringByToday() async throws {
        let routine = Routine(name: "Test Routine")
        routine.days = DateUtility.allWeekdays()
        
        let step1 = Step(name: "Step 1", routine: routine, order: 0, days: routine.days)
        let step2 = Step(name: "Step 2", routine: routine, order: 1, days: [Weekday(rawValue: 2)]) // Only Monday
        
        routine.steps = [step1, step2]
        
        // Both steps should be available today (assuming test runs on a day in the week)
        let todaySteps = (routine.steps ?? []).filter { $0.isToday() }
        #expect(todaySteps.count >= 1) // At least step1 should be available
        
        // Verify step1 is always available
        #expect(step1.isToday() == true)
    }
    
    /// Tests that step status icons are correct
    @Test func stepStatusIcons() async throws {
        let routine = Routine()
        let step = Step(name: "Test Step", routine: routine, order: 0)
        
        #expect(step.status.icon == "circle")
        
        step.status = .complete
        #expect(step.status.icon == "checkmark.circle.fill")
        
        step.status = .skipped
        #expect(step.status.icon == "circle.slash")
    }
}

/// Helper function to generate a date for use in tests
fileprivate func makeTime(hour: Int, minute: Int) -> Date {
    var time = DateComponents()
    time.hour = hour
    time.minute = minute
    
    let calendar = Calendar.current
    guard let tempTime = calendar.date(from: time) else { return Date() }
    
    return tempTime
}
