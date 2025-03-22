//
//  RoutineList.swift
//  Routines
//
//  Created by Sam Clemente on 3/22/25.
//

import SwiftUI
import SwiftData

struct RoutineList: View {
    @Environment(\.modelContext) var modelContext
    @Query var routines: [Routine]
    @Binding var showAllRoutines: Bool
    @Binding var addButtonIsPresented: Bool
    @Binding var routineToEdit: Routine?
    
    let deleteRoutine: (IndexSet) -> Void
    let getTimeComponent: @MainActor @Sendable (Date) -> Date
    
    var body: some View {
        List {
            ForEach(routines.sorted(by: { getTimeComponent($0.time) < getTimeComponent($1.time) }), id: \.id) { routine in
                if routine.isToday() || showAllRoutines {
                    NavigationLink(destination: RoutineStepListView(routine: routine)
                        .onAppear { addButtonIsPresented = false }
                    ) {
                        RoutineCardView(routine: routine, showDetail: $showAllRoutines)
                    }
                    .contextMenu {
                        Button(action: routine.skipRemainingSteps) {
                            Label("Skip Remaining Steps", systemImage: "circle.slash")
                        }
                        Button(action: routine.completeRemainingSteps) {
                            Label("Complete Remaining Steps", systemImage: "checkmark.circle")
                        }
                        Button(action: { routineToEdit = routine }) {
                            Label("Edit \(routine.name)", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: { modelContext.delete(routine) }, label: { Label("Delete \(routine.name)", systemImage: "trash") })
                    }
                }
            }
            .onDelete(perform: deleteRoutine)
        }
    }
}

