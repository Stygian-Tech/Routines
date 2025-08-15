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
    private func todayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    @Test func isTodayTrueWhenIncluded() async throws {
        let routine = Routine()
        let step = Step(name: "A", routine: routine, order: 0, days: [todayName()])
        #expect(step.isToday() == true)
    }
    
    @Test func isTodayFalseWhenExcluded() async throws {
        let routine = Routine()
        var other = "Monday"
        if todayName() == other { other = "Tuesday" }
        let step = Step(name: "A", routine: routine, order: 0, days: [other])
        #expect(step.isToday() == false)
    }
}


