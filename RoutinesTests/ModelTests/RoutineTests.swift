//
//  RoutineTests.swift
//  RoutinesTests
//
//  Created by Sam Clemente on 6/30/24.
//

import Testing
import Foundation
import SwiftUI
@testable import Routines

/// Tests specific to the ``Routine`` class
struct RoutineTests {
    
    /// Ensures that the defaults for the routine class are correct
    @Test func routineCreationDefaults() async throws {
        let routine = Routine()
        #expect(routine.name == "New Routine")
        
        // Exploring how to test this one because the time is going to change between the creation of the object and the assertion
        // #expect(routine.time == Date())
        #expect(routine.iconColor == ".blue")
        #expect(routine.iconSymbol == "list.bullet")
        #expect(routine.steps.isEmpty)
    }
    
    /// Ensures that routines are being created correctly with all properties
    @Test func routineCreationWithValues() async throws {
        let tempTime = makeTime(hour: 6, minute: 0)
        
        // Create the Routine object
        let routine = Routine(name: "Morning Routine", time: tempTime, iconColor: ".yellow", iconSymbol: "sunrise")
        let step = Step(name: "Brush Teeth", routine: routine, order: 0)
        routine.steps = [step]
        
        // Test the creation of the Routine object
        #expect(routine.name == "Morning Routine")
        #expect(routine.time == tempTime)
        #expect(routine.iconColor == ".yellow")
        #expect(routine.iconSymbol == "sunrise")
        #expect(routine.steps.isEmpty == false)
        #expect(routine.steps[0].name == "Brush Teeth")
    }
    
    /// Ensures that the formatting of the time string is correct when displayed in app
    @Test func timeStringConversion() async throws {
        let routine = Routine(time: makeTime(hour: 6, minute: 0))
        let routineString = routine.timeToString()
        #expect(routineString == "6:00 AM")
    }
    
    /// Ensures that, when a ``Routine`` gets copied, a new routine is created instead of a reference to the old routine
    ///
    /// The second routine should not have the same ID and it should not contain any of the steps of the original routine
    @Test func copyRoutine() async throws {
        let routine1 = Routine(name: "Morning Routine", time: makeTime(hour: 6, minute: 0), iconColor: ".yellow", iconSymbol: "sunrise")
        let step = Step(name: "Brush Teeth", routine: routine1, order: 0)
        routine1.steps = [step]
        
        let routine2 = routine1.copy()
        routine2.name = "Evening Routine"
        
        #expect(routine1.id != routine2.id)
        #expect(routine1.name != routine2.name)
        #expect(routine2.steps.isEmpty)
    }
    
    /// Ensures that the color string is properly grabbing the corresponding ``Color`` object
    @Test func gettingCorrectIconColor() async throws {
        let routine = Routine()
        
        #expect(routine.getIconColor() == Color.blue)
    }

}

/// Generates a date for use in the tests
///
/// - Parameters:
///    - hour: the hour for the time (0-23)
///    - minute: the minute for the time (0-59)
/// - Returns: A ``Date`` object containing the specified time
fileprivate func makeTime(hour: Int, minute: Int) -> Date {
    // Create the date
    var time = DateComponents()
    time.hour = hour
    time.minute = minute
    
    // Create the calendar
    let calendar = Calendar.current
    
    // Create the actual date object
    guard let tempTime = calendar.date(from: time) else { return Date()}
    
    return tempTime
}
