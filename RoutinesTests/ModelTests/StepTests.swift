//
//  StepTests.swift
//  RoutinesTests
//
//  Created by Sam Clemente on 7/26/24.
//

import Testing
import Foundation
@testable import Routines

/// All tests for the `Step` class
struct StepTests {
    
    /// Tests creation of a step using the default values
    @Test func stepCreationDefaults() async throws {
        let routine = Routine()
        let step = Step(routine: routine, order: 0)
        
        #expect(step.name == "Step")
        #expect(step.status == .incomplete)
        #expect(step.order == 0)
        #expect(step.routine?.id == routine.id)
    }
    
    /// Tests creation of a step with a name passed to the initializer
    @Test func stepCreationWithValues() async throws {
        let routine = Routine()
        let step = Step(name: "Make Breakfast", routine: routine, order: 1)
        
        #expect(step.name == "Make Breakfast")
        #expect(step.status == .incomplete)
        #expect(step.order == 1)
        #expect(step.routine?.id == routine.id)
    }
}
