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
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Query(sort: [SortDescriptor(\Routine.time, order: .forward)]) private var allRoutines: [Routine]
    @State private var selectedRoutineID: UUID?
    @State private var showingAddRoutine = false
    @State private var showingMenu = false
    @State private var showingResetAlert = false
    @State private var showAllRoutines = false
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    // Computed property to filter routines based on showAllRoutines
    private var displayedRoutines: [Routine] {
        if showAllRoutines {
            return allRoutines
        } else {
            return allRoutines.filter { $0.isToday() }
        }
    }
    
    var body: some View {
        NavigationStack {
            if displayedRoutines.isEmpty {
                WatchEmptyRoutinesView(showingAddRoutine: $showingAddRoutine)
            } else {
                WatchRoutinesListContent(
                    routines: displayedRoutines,
                    showAllRoutines: $showAllRoutines,
                    showingMenu: $showingMenu,
                    showingResetAlert: $showingResetAlert,
                    onReset: resetAllRoutines,
                    onDelete: { routine in
                        Task {
                            do {
                                try await routineManager.deleteRoutines([routine])
                            } catch {
                                print("Error deleting routine: \(error.localizedDescription)")
                            }
                        }
                    }
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
            WatchEditRoutineView(isPresented: $showingAddRoutine)
        }
        .task {
            // Check routine completion on initial load
            do {
                try await routineManager.checkRoutinesCompletion(displayedRoutines)
            } catch {
                print("Error checking routine completion: \(error.localizedDescription)")
            }
        }
        .onChange(of: showingAddRoutine) { _, isPresented in
            // Check completion when add sheet is dismissed
            if !isPresented {
                Task {
                    do {
                        try await routineManager.checkRoutinesCompletion(displayedRoutines)
                    } catch {
                        print("Error checking routine completion: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onChange(of: allRoutines) { _, _ in
            // When routines change (from CloudKit sync), check completion
            Task {
                do {
                    try await routineManager.checkRoutinesCompletion(displayedRoutines)
                } catch {
                    print("Error checking routine completion: \(error.localizedDescription)")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cloudKitSyncCompleted)) { _ in
            // When CloudKit sync completes, check routine completion
            Task {
                do {
                    try await routineManager.checkRoutinesCompletion(displayedRoutines)
                } catch {
                    print("Error checking routine completion: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func resetAllRoutines() {
        Task {
            await resetRoutines(
                displayedRoutines,
                using: routineManager,
                onCompletion: nil // Routines will automatically refresh via @Query
            )
        }
    }
}

