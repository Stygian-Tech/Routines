//
//  EditRoutineSheet.swift
//  Routines
//
//  Created to modularize sheets
//

import SwiftUI
import SwiftData

struct EditRoutineSheet: View {
    let routine: Routine
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            EditRoutineView(routine: routine) { tempRoutine in
                modelContext.delete(tempRoutine)
                isPresented = false
            } onSave: { tempRoutine in
                routine.name = tempRoutine.name
                routine.time = tempRoutine.time
                routine.iconSymbol = tempRoutine.iconSymbol
                routine.iconColor = tempRoutine.iconColor
                routine.days = tempRoutine.days
                modelContext.delete(tempRoutine)
                isPresented = false
            }
            .navigationTitle("Edit \(routine.name)")
        }
    }
}


