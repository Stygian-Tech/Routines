//
//  RoutineStartDateSchedulingTests.swift
//  RoutinesTests
//

import Foundation
import Testing
@testable import Routines

struct RoutineStartDateSchedulingTests {

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var components = DateComponents()
        components.year = y
        components.month = m
        components.day = d
        guard let date = Calendar.current.date(from: components) else {
            Issue.record("Could not build date from components")
            return Date()
        }
        return date
    }

    @Test func longCycleIntervalsUseExplicitStartDate() {
        #expect(RoutineRepeatInterval.weekly.usesLongCycleStartDate == false)
        #expect(RoutineRepeatInterval.fortnightly.usesLongCycleStartDate == true)
        #expect(RoutineRepeatInterval.monthly.usesLongCycleStartDate == true)
        #expect(RoutineRepeatInterval.biMonthly.usesLongCycleStartDate == true)
        #expect(RoutineRepeatInterval.quarterly.usesLongCycleStartDate == true)
        #expect(RoutineRepeatInterval.yearly.usesLongCycleStartDate == true)
    }

    @Test func monthlyNotScheduledBeforeStartDate() {
        let routine = Routine()
        routine.repeatInterval = .monthly
        routine.repeatAnchorDate = date(2024, 6, 15)
        // Tuesday June 11, 2024 — calendar weekday 3 (Apple: Tue)
        routine.days = [Weekday(rawValue: 3)]

        #expect(routine.isScheduled(on: date(2024, 6, 11)) == false)

        // Tuesday June 18, 2024 — same month as anchor, after start
        #expect(routine.isScheduled(on: date(2024, 6, 18)) == true)
    }

    @Test func monthlyScheduledOnStartDay() {
        let routine = Routine()
        routine.repeatInterval = .monthly
        routine.repeatAnchorDate = date(2024, 6, 15)
        // Saturday June 15, 2024 — weekday 7
        routine.days = [Weekday(rawValue: 7)]

        #expect(routine.isScheduled(on: date(2024, 6, 15)) == true)
    }

    @Test func fortnightlyNotScheduledBeforeStartDateEvenWhenPhaseMatches() {
        let routine = Routine()
        routine.repeatInterval = .fortnightly
        let anchor = date(2024, 6, 15)
        routine.repeatAnchorDate = anchor
        routine.days = DateUtility.allWeekdays()

        // Before anchor
        #expect(routine.isScheduled(on: date(2024, 6, 10)) == false)
        // On or after anchor, still must match weekday + biweekly pattern
        #expect(routine.isScheduled(on: anchor) == true)
    }

    @Test func weeklyIgnoresStartDateGate() {
        let routine = Routine()
        routine.repeatInterval = .weekly
        routine.repeatAnchorDate = date(2030, 1, 1)
        let weekday = DateUtility.weekday(for: date(2024, 6, 11))
        routine.days = [weekday]

        #expect(routine.isScheduled(on: date(2024, 6, 11)) == true)
    }

    @Test func stepInactiveBeforeRoutineStartDate() {
        let routine = Routine()
        routine.repeatInterval = .monthly
        routine.repeatAnchorDate = date(2024, 6, 15)
        let w = Weekday(rawValue: 3)
        routine.days = [w]

        let step = Step(name: "A", routine: routine, order: 0, days: [w])
        routine.steps = [step]
        step.routine = routine

        #expect(step.isActive(on: date(2024, 6, 11)) == false)
        #expect(step.isActive(on: date(2024, 6, 18)) == true)
    }
}
