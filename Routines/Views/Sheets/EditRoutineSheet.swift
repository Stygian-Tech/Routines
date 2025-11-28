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
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            EditRoutineView(routine: routine) { tempRoutine in
                modelContext.delete(tempRoutine)
                isPresented = false
            } onSave: { tempRoutine in
                Task {
                    do {
                        try await routineManager.updateRoutine(
                            routine,
                            name: tempRoutine.name,
                            time: tempRoutine.time,
                            iconColor: tempRoutine.iconColor,
                            iconSymbol: tempRoutine.iconSymbol,
                            days: tempRoutine.days
                        )
                modelContext.delete(tempRoutine)
                isPresented = false
                    } catch {
                        print("Error updating routine: \(error.localizedDescription)")
                    }
                }
            }
            .navigationTitle("Edit \(routine.name)")
        }
    }
}


