//
//  AddRoutineSheet.swift
//  Routines
//
//  Created to modularize sheets
//

import SwiftUI
import SwiftData

struct AddRoutineSheet: View {
    @Binding var newRoutine: Routine?
    @Binding var isPresented: Bool
    var modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            EditRoutineView(routine: newRoutine ?? Routine(), onDismiss: { _ in
                if let temp = newRoutine { modelContext.delete(temp) }
                isPresented = false
            }, onSave: { tempRoutine in
                if let routine = newRoutine {
                    routine.name = tempRoutine.name
                    routine.time = tempRoutine.time
                    routine.iconSymbol = tempRoutine.iconSymbol
                    routine.iconColor = tempRoutine.iconColor
                    routine.repeatInterval = tempRoutine.repeatInterval
                    routine.repeatAnchorDate = tempRoutine.repeatAnchorDate
                    routine.days = tempRoutine.days
                }
                isPresented = false
            })
            .navigationTitle("New Routine")
        }
    }
}

