//
//  RoutineDaySynchronizerTests.swift
//  RoutinesTests
//
//  Tests for routine-step day synchronization logic
//

import XCTest
import SwiftData
@testable import Routines

@MainActor
final class RoutineDaySynchronizerTests: XCTestCase {
    
    var modelContext: ModelContext!
    var synchronizer: RoutineDaySynchronizer!
    
    override func setUpWithError() throws {
        modelContext = try UnitTestModelContainer.makeFreshContext()
        synchronizer = RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    override func tearDownWithError() throws {
        modelContext = nil
        synchronizer = nil
    }
    
    // MARK: - Helper Methods
    
    private func createRoutine(days: [Weekday] = DateUtility.allWeekdays()) -> Routine {
        let routine = Routine(name: "Test Routine", days: days)
        modelContext.insert(routine)
        return routine
    }
    
    private func createStep(in routine: Routine, days: [Weekday]) -> Step {
        let step = Step(name: "Test Step", routine: routine, order: routine.steps?.count ?? 0, days: days)
        modelContext.insert(step)
        routine.steps = (routine.steps ?? []) + [step]
        return step
    }
    
    // MARK: - Compute Required Days Tests
    
    func testComputeRequiredDays_EmptySteps_ReturnsEmpty() {
        let routine = createRoutine()
        
        let requiredDays = synchronizer.computeRequiredDays(for: routine)
        
        XCTAssertTrue(requiredDays.isEmpty)
    }
    
    func testComputeRequiredDays_SingleStep_ReturnsStepDays() {
        let routine = createRoutine()
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        _ = createStep(in: routine, days: [monday, wednesday])
        
        let requiredDays = synchronizer.computeRequiredDays(for: routine)
        
        XCTAssertEqual(Set(requiredDays), Set([monday, wednesday]))
    }
    
    func testComputeRequiredDays_MultipleSteps_ReturnsUnion() {
        let routine = createRoutine()
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let friday = Weekday(rawValue: 6)
        _ = createStep(in: routine, days: [monday, wednesday])
        _ = createStep(in: routine, days: [wednesday, friday])
        
        let requiredDays = synchronizer.computeRequiredDays(for: routine)
        
        XCTAssertEqual(Set(requiredDays), Set([monday, wednesday, friday]))
    }
    
    // MARK: - Is Day Used By Any Step Tests
    
    func testIsDayUsedByAnyStep_DayUsed_ReturnsTrue() {
        let routine = createRoutine()
        let monday = Weekday(rawValue: 2)
        _ = createStep(in: routine, days: [monday])
        
        let isUsed = synchronizer.isDayUsedByAnyStep(monday, in: routine)
        
        XCTAssertTrue(isUsed)
    }
    
    func testIsDayUsedByAnyStep_DayNotUsed_ReturnsFalse() {
        let routine = createRoutine()
        let monday = Weekday(rawValue: 2)
        let tuesday = Weekday(rawValue: 3)
        _ = createStep(in: routine, days: [monday])
        
        let isUsed = synchronizer.isDayUsedByAnyStep(tuesday, in: routine)
        
        XCTAssertFalse(isUsed)
    }
    
    func testIsDayUsedByAnyStep_ExcludingStep_IgnoresExcludedStep() {
        let routine = createRoutine()
        let monday = Weekday(rawValue: 2)
        let step = createStep(in: routine, days: [monday])
        
        let isUsed = synchronizer.isDayUsedByAnyStep(monday, in: routine, excludingStep: step)
        
        XCTAssertFalse(isUsed)
    }
    
    func testIsDayUsedByAnyStep_ExcludingStep_ConsidersOtherSteps() {
        let routine = createRoutine()
        let monday = Weekday(rawValue: 2)
        let stepA = createStep(in: routine, days: [monday])
        _ = createStep(in: routine, days: [monday])
        
        let isUsed = synchronizer.isDayUsedByAnyStep(monday, in: routine, excludingStep: stepA)
        
        XCTAssertTrue(isUsed)
    }
    
    // MARK: - Add Day To Step Tests
    
    func testAddDayToStep_DayInRoutine_OnlyUpdatesStep() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        let step = createStep(in: routine, days: [monday])
        
        synchronizer.addDayToStep(step, day: wednesday, routine: routine)
        
        XCTAssertTrue(step.days.contains(wednesday))
        XCTAssertEqual(Set(routine.days), Set([monday, wednesday]))
    }
    
    func testAddDayToStep_DayNotInRoutine_ExpandsRoutine() {
        let monday = Weekday(rawValue: 2)
        let friday = Weekday(rawValue: 6)
        let routine = createRoutine(days: [monday])
        let step = createStep(in: routine, days: [monday])
        
        synchronizer.addDayToStep(step, day: friday, routine: routine)
        
        XCTAssertTrue(step.days.contains(friday))
        XCTAssertTrue(routine.days.contains(friday))
    }
    
    func testAddDayToStep_DayAlreadyInStep_NoChange() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        let step = createStep(in: routine, days: [monday])
        let originalStepDays = step.days
        
        synchronizer.addDayToStep(step, day: monday, routine: routine)
        
        XCTAssertEqual(step.days, originalStepDays)
    }
    
    // MARK: - Remove Day From Step Tests
    
    func testRemoveDayFromStep_OtherStepUsesDay_KeepsRoutineDay() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        let stepA = createStep(in: routine, days: [monday])
        _ = createStep(in: routine, days: [monday])
        
        synchronizer.removeDayFromStep(stepA, day: monday, routine: routine)
        
        XCTAssertFalse(stepA.days.contains(monday))
        XCTAssertTrue(routine.days.contains(monday))
    }
    
    func testRemoveDayFromStep_NoOtherStepUsesDay_ShrinksRoutine() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        let step = createStep(in: routine, days: [monday, wednesday])
        
        synchronizer.removeDayFromStep(step, day: wednesday, routine: routine)
        
        XCTAssertFalse(step.days.contains(wednesday))
        XCTAssertFalse(routine.days.contains(wednesday))
        XCTAssertTrue(routine.days.contains(monday))
    }
    
    // MARK: - Toggle Day For Step Tests
    
    func testToggleDayForStep_AddDay_AddsToBothStepAndRoutine() {
        let monday = Weekday(rawValue: 2)
        let friday = Weekday(rawValue: 6)
        let routine = createRoutine(days: [monday])
        let step = createStep(in: routine, days: [monday])
        
        synchronizer.toggleDayForStep(step, day: friday, routine: routine)
        
        XCTAssertTrue(step.days.contains(friday))
        XCTAssertTrue(routine.days.contains(friday))
    }
    
    func testToggleDayForStep_RemoveDay_RemovesFromStepAndMaybeRoutine() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        let step = createStep(in: routine, days: [monday])
        
        synchronizer.toggleDayForStep(step, day: monday, routine: routine)
        
        XCTAssertFalse(step.days.contains(monday))
        XCTAssertFalse(routine.days.contains(monday))
    }
    
    // MARK: - Would Orphan Any Step Tests
    
    func testWouldOrphanAnyStep_StepHasMultipleDays_ReturnsFalse() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday, wednesday])
        
        let wouldOrphan = synchronizer.wouldOrphanAnyStep(monday, in: routine)
        
        XCTAssertFalse(wouldOrphan)
    }
    
    func testWouldOrphanAnyStep_StepHasOnlyThisDay_ReturnsTrue() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        _ = createStep(in: routine, days: [monday])
        
        let wouldOrphan = synchronizer.wouldOrphanAnyStep(monday, in: routine)
        
        XCTAssertTrue(wouldOrphan)
    }
    
    func testWouldOrphanAnyStep_NoSteps_ReturnsFalse() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        
        let wouldOrphan = synchronizer.wouldOrphanAnyStep(monday, in: routine)
        
        XCTAssertFalse(wouldOrphan)
    }
    
    // MARK: - Get Days That Would Orphan Steps Tests
    
    func testGetDaysThatWouldOrphanSteps_StepWithOneDay_ReturnsDay() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday])
        _ = createStep(in: routine, days: [monday, wednesday])
        
        let lockedDays = synchronizer.getDaysThatWouldOrphanSteps(in: routine)
        
        XCTAssertEqual(lockedDays, Set([monday]))
    }
    
    func testGetDaysThatWouldOrphanSteps_AllStepsHaveMultipleDays_ReturnsEmpty() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday, wednesday])
        
        let lockedDays = synchronizer.getDaysThatWouldOrphanSteps(in: routine)
        
        XCTAssertTrue(lockedDays.isEmpty)
    }
    
    // MARK: - Can Remove Day From Routine Tests
    
    func testCanRemoveDayFromRoutine_NoStepUsesDay_ReturnsTrue() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday])
        
        let canRemove = synchronizer.canRemoveDayFromRoutine(wednesday, routine: routine)
        
        XCTAssertTrue(canRemove)
    }
    
    func testCanRemoveDayFromRoutine_StepUsesDayButHasOthers_ReturnsTrue() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday, wednesday])
        
        let canRemove = synchronizer.canRemoveDayFromRoutine(monday, routine: routine)
        
        XCTAssertTrue(canRemove)
    }
    
    func testCanRemoveDayFromRoutine_StepOnlyHasThisDay_ReturnsFalse() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        _ = createStep(in: routine, days: [monday])
        
        let canRemove = synchronizer.canRemoveDayFromRoutine(monday, routine: routine)
        
        XCTAssertFalse(canRemove)
    }
    
    // MARK: - Cascade Remove Day From Routine Tests
    
    func testCascadeRemoveDayFromRoutine_RemovesDayFromRoutineAndSteps() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        let step = createStep(in: routine, days: [monday, wednesday])
        
        let removed = synchronizer.cascadeRemoveDayFromRoutine(monday, routine: routine)
        
        XCTAssertTrue(removed)
        XCTAssertFalse(routine.days.contains(monday))
        XCTAssertFalse(step.days.contains(monday))
        XCTAssertTrue(routine.days.contains(wednesday))
        XCTAssertTrue(step.days.contains(wednesday))
    }
    
    func testCascadeRemoveDayFromRoutine_WouldOrphanStep_PreventsRemoval() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        let step = createStep(in: routine, days: [monday])
        
        let removed = synchronizer.cascadeRemoveDayFromRoutine(monday, routine: routine)
        
        XCTAssertFalse(removed)
        XCTAssertTrue(routine.days.contains(monday))
        XCTAssertTrue(step.days.contains(monday))
    }
    
    func testCascadeRemoveDayFromRoutine_NoStepsHaveDay_RemovesFromRoutineOnly() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        let step = createStep(in: routine, days: [monday])
        
        let removed = synchronizer.cascadeRemoveDayFromRoutine(wednesday, routine: routine)
        
        XCTAssertTrue(removed)
        XCTAssertFalse(routine.days.contains(wednesday))
        XCTAssertTrue(step.days.contains(monday))
    }
    
    // MARK: - Toggle Day For Routine Tests
    
    func testToggleDayForRoutine_AddDay_AddsDay() {
        let monday = Weekday(rawValue: 2)
        let friday = Weekday(rawValue: 6)
        let routine = createRoutine(days: [monday])
        
        let success = synchronizer.toggleDayForRoutine(friday, routine: routine)
        
        XCTAssertTrue(success)
        XCTAssertTrue(routine.days.contains(friday))
    }
    
    func testToggleDayForRoutine_RemoveUnusedDay_RemovesDay() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        _ = createStep(in: routine, days: [monday])
        
        let success = synchronizer.toggleDayForRoutine(wednesday, routine: routine)
        
        XCTAssertTrue(success)
        XCTAssertFalse(routine.days.contains(wednesday))
    }
    
    func testToggleDayForRoutine_RemoveUsedDay_CascadesToSteps() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let routine = createRoutine(days: [monday, wednesday])
        let step = createStep(in: routine, days: [monday, wednesday])
        
        let success = synchronizer.toggleDayForRoutine(monday, routine: routine)
        
        XCTAssertTrue(success)
        XCTAssertFalse(routine.days.contains(monday))
        XCTAssertFalse(step.days.contains(monday))
    }
    
    func testToggleDayForRoutine_WouldOrphanStep_PreventsRemoval() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        let step = createStep(in: routine, days: [monday])
        
        let success = synchronizer.toggleDayForRoutine(monday, routine: routine)
        
        XCTAssertFalse(success)
        XCTAssertTrue(routine.days.contains(monday))
        XCTAssertTrue(step.days.contains(monday))
    }
    
    // MARK: - Synchronize Routine Days Tests
    
    func testSynchronizeRoutineDays_AddsRequiredDays() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let friday = Weekday(rawValue: 6)
        let routine = createRoutine(days: [monday])
        
        // Directly set step days that aren't in routine (simulating a data inconsistency)
        let step = Step(name: "Test", routine: routine, order: 0, days: [monday, wednesday, friday])
        modelContext.insert(step)
        routine.steps = (routine.steps ?? []) + [step]

        synchronizer.synchronizeRoutineDays(routine)
        
        XCTAssertTrue(routine.days.contains(monday))
        XCTAssertTrue(routine.days.contains(wednesday))
        XCTAssertTrue(routine.days.contains(friday))
    }
    
    func testSynchronizeRoutineDays_RemovesUnusedDays() {
        let monday = Weekday(rawValue: 2)
        let wednesday = Weekday(rawValue: 4)
        let friday = Weekday(rawValue: 6)
        let routine = createRoutine(days: [monday, wednesday, friday])
        _ = createStep(in: routine, days: [monday])
        
        synchronizer.synchronizeRoutineDays(routine)
        
        XCTAssertTrue(routine.days.contains(monday))
        XCTAssertFalse(routine.days.contains(wednesday))
        XCTAssertFalse(routine.days.contains(friday))
    }
    
    func testSynchronizeRoutineDays_EmptySteps_ClearsRoutineDays() {
        let monday = Weekday(rawValue: 2)
        let routine = createRoutine(days: [monday])
        
        synchronizer.synchronizeRoutineDays(routine)
        
        XCTAssertTrue(routine.days.isEmpty)
    }
}
