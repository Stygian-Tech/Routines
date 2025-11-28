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
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Routines")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                    
                    Button(action: {
                        showingAddRoutine = true
                    }) {
                        Label("Create Routine", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                .navigationTitle("Routines")
            } else {
                List {
                    ForEach(routines) { routine in
                        NavigationLink(value: routine.id) {
                           WatchRoutineRowView(routine: routine)
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
                        resetAllRoutines()
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
