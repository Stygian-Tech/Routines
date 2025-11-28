//
//  DateUtilityTests.swift
//  RoutinesTests
//
//  Created by AI on 12/19/24.
//

import Testing
import Foundation
@testable import Routines

struct DateUtilityTests {
    
    // MARK: - Weekday Conversion Tests
    
    @Test func weekdayFromStringEnglish() async throws {
        let monday = DateUtility.weekdayFromString("Monday")
        #expect(monday != nil)
        #expect(monday?.calendarWeekday == 2)
        
        let sunday = DateUtility.weekdayFromString("Sunday")
        #expect(sunday != nil)
        #expect(sunday?.calendarWeekday == 1)
    }
    
    @Test func weekdayFromStringAbbreviated() async throws {
        let mon = DateUtility.weekdayFromString("Mon")
        #expect(mon != nil)
        #expect(mon?.calendarWeekday == 2)
        
        let sun = DateUtility.weekdayFromString("Sun")
        #expect(sun != nil)
        #expect(sun?.calendarWeekday == 1)
    }
    
    @Test func weekdayFromStringCaseInsensitive() async throws {
        let monday1 = DateUtility.weekdayFromString("MONDAY")
        let monday2 = DateUtility.weekdayFromString("monday")
        let monday3 = DateUtility.weekdayFromString("Monday")
        
        #expect(monday1?.rawValue == monday2?.rawValue)
        #expect(monday2?.rawValue == monday3?.rawValue)
    }
    
    @Test func weekdayFromStringInvalid() async throws {
        let invalid = DateUtility.weekdayFromString("InvalidDay")
        #expect(invalid == nil)
    }
    
    @Test func weekdaysFromStrings() async throws {
        let dayStrings = ["Monday", "Wednesday", "Friday"]
        let weekdays = DateUtility.weekdaysFromStrings(dayStrings)
        
        #expect(weekdays.count == 3)
        #expect(weekdays.contains(Weekday(rawValue: 2))) // Monday
        #expect(weekdays.contains(Weekday(rawValue: 4))) // Wednesday
        #expect(weekdays.contains(Weekday(rawValue: 6))) // Friday
    }
    
    @Test func weekdaysFromStringsEmpty() async throws {
        let weekdays = DateUtility.weekdaysFromStrings([])
        // Should return all weekdays as default
        #expect(weekdays.count == 7)
    }
    
    @Test func weekdaysFromStringsInvalid() async throws {
        let dayStrings = ["InvalidDay", "AnotherInvalid"]
        let weekdays = DateUtility.weekdaysFromStrings(dayStrings)
        // Should return all weekdays as default when no valid days found
        #expect(weekdays.count == 7)
    }
    
    // MARK: - Display Name Tests
    
    @Test func displayNameReturnsNonEmpty() async throws {
        let weekday = Weekday(rawValue: 2) // Monday
        let displayName = DateUtility.displayName(for: weekday)
        
        #expect(!displayName.isEmpty)
    }
    
    @Test func displayNameConsistent() async throws {
        let weekday = Weekday(rawValue: 2) // Monday
        let name1 = DateUtility.displayName(for: weekday)
        let name2 = DateUtility.displayName(for: weekday)
        
        #expect(name1 == name2)
    }
    
    @Test func abbreviatedDisplayNameReturnsSingleCharacter() async throws {
        let weekday = Weekday(rawValue: 2) // Monday
        let abbreviated = DateUtility.abbreviatedDisplayName(for: weekday)
        
        #expect(!abbreviated.isEmpty)
        // Should be a single character or very short
        #expect(abbreviated.count <= 3)
    }
    
    // MARK: - All Weekdays Tests
    
    @Test func allWeekdaysReturnsSeven() async throws {
        let weekdays = DateUtility.allWeekdays()
        #expect(weekdays.count == 7)
    }
    
    @Test func allWeekdaysContainsAllValues() async throws {
        let weekdays = DateUtility.allWeekdays()
        let values = Set(weekdays.map { $0.rawValue })
        
        // Should contain all values from 1-7
        #expect(values.count == 7)
        for i in 1...7 {
            #expect(values.contains(i))
        }
    }
    
    @Test func allWeekdaysOrderedByFirstWeekday() async throws {
        let weekdays = DateUtility.allWeekdays()
        let firstWeekday = DateUtility.firstWeekday
        
        // First weekday should match system's first weekday
        #expect(weekdays.first?.rawValue == firstWeekday)
    }
    
    // MARK: - Today Tests
    
    @Test func todayWeekdayReturnsValid() async throws {
        let today = DateUtility.todayWeekday()
        #expect(today.rawValue >= 1)
        #expect(today.rawValue <= 7)
    }
    
    @Test func isTodayMatchesToday() async throws {
        let today = DateUtility.todayWeekday()
        let isToday = DateUtility.isToday(today)
        #expect(isToday == true)
    }
    
    @Test func isTodayFalseForOtherDay() async throws {
        // Get a day that's not today
        let today = DateUtility.todayWeekday()
        let tomorrow = Weekday(rawValue: ((today.rawValue % 7) + 1))
        
        // If tomorrow is actually today (edge case), skip this test
        if tomorrow == today {
            return
        }
        
        let isToday = DateUtility.isToday(tomorrow)
        #expect(isToday == false)
    }
    
    // MARK: - Calendar Detection Tests
    
    @Test func currentCalendarIsValid() async throws {
        let calendar = DateUtility.currentCalendar
        #expect(calendar.identifier == Calendar.current.identifier)
    }
    
    @Test func firstWeekdayIsValid() async throws {
        let firstWeekday = DateUtility.firstWeekday
        #expect(firstWeekday >= 1)
        #expect(firstWeekday <= 7)
    }
}

