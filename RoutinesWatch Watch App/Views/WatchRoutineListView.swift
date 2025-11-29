//
//  WatchRoutineListView.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData

struct WatchRoutineListView: View {
    @Environment(\.modelContext) var modelContext
    @State private var routines: [Routine] = []
    @State private var selectedRoutineID: UUID?
    @State private var showingAddRoutine = false
    @State private var showingMenu = false
    @State private var showingResetAlert = false
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            if routines.isEmpty {
                WatchEmptyRoutinesView(showingAddRoutine: $showingAddRoutine)
            } else {
                WatchRoutinesListContent(
                    routines: routines,
                    showingMenu: $showingMenu,
                    showingResetAlert: $showingResetAlert,
                    onReset: resetAllRoutines
                )
            }
        }
        .sheet(isPresented: $showingMenu) {
            WatchMenuView(
                isPresented: $showingMenu,
                showingAddRoutine: $showingAddRoutine,
                onResetSelected: {
                    showingResetAlert = true
                }
            )
        }
        .sheet(isPresented: $showingAddRoutine) {
            WatchAddRoutineView(isPresented: $showingAddRoutine)
        }
        .task {
            // Fetch today's routines and check completion on appear
            do {
                routines = try await routineManager.getTodayRoutines()
                try await routineManager.checkRoutinesCompletion(routines)
            } catch {
                print("Error fetching routines: \(error.localizedDescription)")
            }
        }
        .onChange(of: showingAddRoutine) { _, isPresented in
            // Refresh routines when add sheet is dismissed
            if !isPresented {
                Task {
                    do {
                        routines = try await routineManager.getTodayRoutines()
                        try await routineManager.checkRoutinesCompletion(routines)
                    } catch {
                        print("Error refreshing routines: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func resetAllRoutines() {
        Task {
            do {
                try await routineManager.resetRoutines(routines)
                try await routineManager.save()
                // Refresh routines after reset
                routines = try await routineManager.getTodayRoutines()
                try await routineManager.checkRoutinesCompletion(routines)
            } catch {
                print("Error resetting routines: \(error.localizedDescription)")
            }
        }
    }
}
