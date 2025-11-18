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
    @Query(sort: [SortDescriptor(\Routine.time, order: .forward)]) var routines: [Routine]
    @Binding var showAllRoutines: Bool
    @Binding var routineToEdit: Routine?
    @Binding var showRoutineDetails: Bool

    let deleteRoutine: ([Routine]) -> Void

    var body: some View {
        let displayedRoutines = routines.filter { $0.isToday() || showAllRoutines }
        List {
            ForEach(displayedRoutines, id: \.id) { routine in
                NavigationLink(value: routine.id) {
                    RoutineCardView(routine: routine, showDetail: $showRoutineDetails)
                }
                .accessibilityLabel(Text(routine.name))
                .accessibilityHint(Text("Opens routine"))
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
            .onDelete { indexSet in
                let targets = indexSet.map { displayedRoutines[$0] }
                deleteRoutine(targets)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}

