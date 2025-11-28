//
//  StepLogicTests.swift
//  RoutinesTests
//
//  Created by AI on 8/15/25.
//

import Testing
import Foundation
@testable import Routines

struct StepLogicTests {
    private func todayWeekday() -> Weekday {
        DateUtility.todayWeekday()
    }
    
    @Test func isTodayTrueWhenIncluded() async throws {
        let routine = Routine()
        let today = todayWeekday()
        let step = Step(name: "A", routine: routine, order: 0, days: [today])
        #expect(step.isToday() == true)
    }
    
    @Test func isTodayFalseWhenExcluded() async throws {
        let routine = Routine()
        let today = todayWeekday()
        // Pick a day that is not today
        let otherDay = Weekday(rawValue: ((today.rawValue % 7) + 1))
        let step = Step(name: "A", routine: routine, order: 0, days: [otherDay])
        #expect(step.isToday() == false)
    }
}


