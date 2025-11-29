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
    @State private var showAllRoutines = false
    
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
                showAllRoutines: $showAllRoutines,
                onResetSelected: {
                    showingResetAlert = true
                }
            )
        }
        .sheet(isPresented: $showingAddRoutine) {
            WatchAddRoutineView(isPresented: $showingAddRoutine)
        }
        .task {
            await loadRoutines()
        }
        .onChange(of: showingAddRoutine) { _, isPresented in
            // Refresh routines when add sheet is dismissed
            if !isPresented {
                Task {
                    await loadRoutines()
                }
            }
        }
        .onChange(of: showAllRoutines) { _, _ in
            // Reload routines when toggle changes
            Task {
                await loadRoutines()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadRoutines() async {
        do {
            if showAllRoutines {
                routines = try await routineManager.getAllRoutines()
            } else {
                routines = try await routineManager.getTodayRoutines()
            }
            try await routineManager.checkRoutinesCompletion(routines)
        } catch {
            print("Error fetching routines: \(error.localizedDescription)")
        }
    }
    
    private func resetAllRoutines() {
        Task {
            await resetRoutines(
                routines,
                using: routineManager,
                onCompletion: {
                    // Refresh routines after reset
                    await loadRoutines()
                }
            )
        }
    }
}
