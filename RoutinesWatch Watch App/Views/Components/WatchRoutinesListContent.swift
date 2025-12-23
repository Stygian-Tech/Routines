//
//  WatchRoutinesListContent.swift
//  RoutinesWatch
//
//  Created by AI on 12/19/24.
//

import SwiftUI

struct WatchRoutinesListContent: View {
    let routines: [Routine]
    @Binding var showingMenu: Bool
    @Binding var showingResetAlert: Bool
    let onReset: () -> Void
    let onDelete: (Routine) -> Void
    
    var body: some View {
        List {
            ForEach(routines) { routine in
                NavigationLink(value: routine.id) {
                    WatchRoutineRowView(
                        routine: routine,
                        onDelete: { routine in onDelete(routine) }
                    )
                }
            }
        }
        .navigationTitle("Routines")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingMenu = true
                }) {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More Options")
            }
            ToolbarItem(placement: .topBarLeading) {
            }
        }
        .alert("Reset All Routines?", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                onReset()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset all routines to incomplete.")
        }
        .navigationDestination(for: UUID.self) { id in
            if let routine = routines.first(where: { $0.id == id }) {
                WatchRoutineDetailView(routine: routine)
            } else {
                Text("Routine Not Found")
            }
        }
    }
}

