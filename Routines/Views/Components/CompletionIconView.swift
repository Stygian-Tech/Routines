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
    
    var body: some View {
        Image(systemName: "checkmark.circle")
            .symbolRenderingMode(.palette)
            .foregroundStyle(routine.status.icon.iconColor2 ?? routine.status.icon.iconColor1, routine.status.icon.iconColor1)
            .padding(.leading, 3)
            .accessibilityHidden(true)
    }
}
