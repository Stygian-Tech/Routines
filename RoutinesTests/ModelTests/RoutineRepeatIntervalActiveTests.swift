//
//  RoutineRepeatIntervalActiveTests.swift
//  RoutinesTests
//

import Foundation
import Testing
@testable import Routines

struct RoutineRepeatIntervalActiveTests {

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

    // MARK: - Month-based

    @Test func monthlyMatchesEveryMonthFromAnchorMonth() {
        let routine = Routine()
        routine.repeatInterval = .monthly
        routine.repeatAnchorDate = date(2024, 1, 15)
        #expect(routine.isRepeatIntervalActive(on: date(2024, 1, 20)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 2, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2025, 6, 30)))
    }

    @Test func biMonthlyActiveOnlyOnEvenMonthOffsets() {
        let routine = Routine()
        routine.repeatInterval = .biMonthly
        routine.repeatAnchorDate = date(2024, 1, 1)
        #expect(routine.isRepeatIntervalActive(on: date(2024, 1, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 3, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 4, 1)) == false) // +3 months from Jan
        #expect(routine.isRepeatIntervalActive(on: date(2024, 5, 15)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 7, 1)))
    }

    @Test func quarterlyEveryThreeMonths() {
        let routine = Routine()
        routine.repeatInterval = .quarterly
        routine.repeatAnchorDate = date(2024, 1, 1)
        #expect(routine.isRepeatIntervalActive(on: date(2024, 1, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 4, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 2, 1)) == false)
        #expect(routine.isRepeatIntervalActive(on: date(2024, 5, 1)) == false)
        #expect(routine.isRepeatIntervalActive(on: date(2024, 7, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2024, 10, 1)))
    }

    @Test func yearlyMatchesSameMonthEachYear() {
        let routine = Routine()
        routine.repeatInterval = .yearly
        routine.repeatAnchorDate = date(2024, 3, 10)
        #expect(routine.isRepeatIntervalActive(on: date(2024, 3, 10)))
        #expect(routine.isRepeatIntervalActive(on: date(2025, 3, 1)))
        #expect(routine.isRepeatIntervalActive(on: date(2025, 9, 10)) == false)
    }

    // MARK: - Week-based (regression)

    @Test func weeklyEveryWeek() {
        let routine = Routine()
        routine.repeatInterval = .weekly
        let anchor = date(2024, 6, 3)
        routine.repeatAnchorDate = anchor
        #expect(routine.isRepeatIntervalActive(on: anchor))
        guard let oneWeekLater = Calendar.current.date(byAdding: .day, value: 7, to: anchor) else {
            Issue.record("date math failed")
            return
        }
        #expect(routine.isRepeatIntervalActive(on: oneWeekLater))
    }

    @Test func fortnightlySkipsEveryOtherWeek() {
        let routine = Routine()
        routine.repeatInterval = .fortnightly
        let anchor = date(2024, 6, 3)
        routine.repeatAnchorDate = anchor
        guard let oneWeekLater = Calendar.current.date(byAdding: .day, value: 7, to: anchor),
              let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 14, to: anchor) else {
            Issue.record("date math failed")
            return
        }
        #expect(routine.isRepeatIntervalActive(on: anchor))
        #expect(routine.isRepeatIntervalActive(on: oneWeekLater) == false)
        #expect(routine.isRepeatIntervalActive(on: twoWeeksLater))
    }
}
