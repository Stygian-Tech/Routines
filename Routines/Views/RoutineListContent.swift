//
//  RoutineListContent.swift
//  Routines
//
//  Created by Sam Clemente on 3/22/25.
//

import SwiftUI
import SwiftData

struct RoutineListContent: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Query(sort: [SortDescriptor(\Routine.time, order: .forward)]) var routines: [Routine]
    @Binding var showAllRoutines: Bool
    @Binding var routineToEdit: Routine?

    let deleteRoutine: ([Routine]) -> Void
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var displayedRoutines: [Routine] {
        if showAllRoutines {
            return routines
        } else {
            return routines.filter { $0.isToday() }
        }
    }

    var body: some View {
        List {
            ForEach(displayedRoutines, id: \.id) { routine in
                NavigationLink(value: routine.id) {
                    RoutineCardView(routine: routine)
                }
                .listRowBackground(.liquidGlass)
                .accessibilityLabel(Text(routine.name))
                .accessibilityHint(Text("Opens routine"))
                .contextMenu {
                    Button(action: {
                        Task {
                            do {
                                try await routineManager.skipRemainingSteps(routine)
                            } catch {
                                print("Error skipping steps: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Label("Skip Remaining Steps", systemImage: "circle.slash")
                    }
                    Button(action: {
                        Task {
                            do {
                                try await routineManager.completeRemainingSteps(routine)
                            } catch {
                                print("Error completing steps: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Label("Complete Remaining Steps", systemImage: "checkmark.circle")
                    }
                    Button(action: { routineToEdit = routine }) {
                        Label("Edit \(routine.name)", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { deleteRoutine([routine]) }, label: { Label("Delete \(routine.name)", systemImage: "trash") })
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

