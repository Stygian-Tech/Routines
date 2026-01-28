//
//  RoutineCompletionIcon.swift
//  Routines
//
//  Created by Sam Clemente on 11/28/25.
//
import SwiftUI


struct CompletionIconView: View {
    let routine: Routine
    
    init(for routine: Routine) {
        self.routine = routine
    }
    
    private var accessibilityLabelForStatus: String {
        switch routine.status {
        case .incomplete:
            return "Incomplete"
        case .complete:
            return "Complete"
        case .completeWithSkippedSteps:
            return "Complete with skipped steps"
        }
    }
    
    var body: some View {
        Image(systemName: "checkmark.circle")
            .symbolRenderingMode(.palette)
            .foregroundStyle(routine.status.icon.iconColor2 ?? routine.status.icon.iconColor1, routine.status.icon.iconColor1)
            .padding(.leading, 3)
            .accessibilityLabel(accessibilityLabelForStatus)
    }
}
