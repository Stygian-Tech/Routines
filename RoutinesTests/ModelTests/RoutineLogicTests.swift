//
//  RoutineLogicTests.swift
//  RoutinesTests
//
//  Created by AI on 8/15/25.
//

import Testing
import Foundation
import SwiftUI
@testable import Routines

struct RoutineLogicTests {
    
    private func todayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    @Test func routineIsTodayTrueWhenDayIncluded() async throws {
        let routine = Routine()
        routine.days = [todayName()]
        #expect(routine.isToday() == true)
    }
    
    @Test func routineIsTodayFalseWhenDayExcluded() async throws {
        let routine = Routine()
        routine.days = ["Monday"]
        // Pick a day that is guaranteed not to be the only day in the set by adding a different one than today
        if todayName() == "Monday" { routine.days = ["Tuesday"] }
        #expect(routine.isToday() == false)
    }
    
    @Test func resetStepsResetsAllState() async throws {
        let routine = Routine()
        routine.days = [todayName()]
        let step1 = Step(name: "A", routine: routine, order: 0, days: [todayName()])
        let step2 = Step(name: "B", routine: routine, order: 1, days: [todayName()])
        routine.steps = [step1, step2]
        step1.status = .complete
        step2.status = .skipped
        routine.status = .complete
        routine.finishedStepCount = 2
        
        routine.resetSteps()
        
        #expect(step1.status == .incomplete)
        #expect(step2.status == .incomplete)
        #expect(routine.status == .incomplete)
        #expect(routine.finishedStepCount == 0)
    }
    
    @Test func skipRemainingStepsMarksIncompleteAsSkipped() async throws {
        let routine = Routine()
        routine.days = [todayName()]
        let step1 = Step(name: "A", routine: routine, order: 0, days: [todayName()])
        let step2 = Step(name: "B", routine: routine, order: 1, days: [todayName()])
        let step3 = Step(name: "C", routine: routine, order: 2, days: [todayName()])
        routine.steps = [step1, step2, step3]
        step1.status = .complete
        step2.status = .incomplete
        step3.status = .incomplete
        
        routine.skipRemainingSteps()
        routine.checkRoutineCompletion()
        
        #expect(step1.status == .complete)
        #expect(step2.status == .skipped)
        #expect(step3.status == .skipped)
        #expect(routine.status == .completeWithSkippedSteps)
        #expect(routine.finishedStepCount == 3)
    }
    
    @Test func completeRemainingStepsMarksIncompleteAsComplete() async throws {
        let routine = Routine()
        routine.days = [todayName()]
        let step1 = Step(name: "A", routine: routine, order: 0, days: [todayName()])
        let step2 = Step(name: "B", routine: routine, order: 1, days: [todayName()])
        routine.steps = [step1, step2]
        step1.status = .complete
        step2.status = .incomplete
        
        routine.completeRemainingSteps()
        routine.checkRoutineCompletion()
        
        #expect(step1.status == .complete)
        #expect(step2.status == .complete)
        #expect(routine.status == .complete)
        #expect(routine.finishedStepCount == 2)
    }
}


