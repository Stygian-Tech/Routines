//
//  EnumsAndUtilsTests.swift
//  RoutinesTests
//
//  Created by AI on 8/15/25.
//

import Testing
import SwiftUI
@testable import Routines

struct EnumsAndUtilsTests {
    @Test func stepCompletionStatusIcons() async throws {
        #expect(StepCompletionStatus.incomplete.icon == "circle")
        #expect(StepCompletionStatus.complete.icon == "checkmark.circle.fill")
        #expect(StepCompletionStatus.skipped.icon == "circle.slash")
    }
    
    @Test func routineCompletionStatusIcons() async throws {
        #expect(RoutineCompletionStatus.incomplete.icon.iconColor1 == .clear)
        #expect(RoutineCompletionStatus.complete.icon.iconColor1 == .green)
        #expect(RoutineCompletionStatus.completeWithSkippedSteps.icon.iconColor2 == .yellow)
    }
}


