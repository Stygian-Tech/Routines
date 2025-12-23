//
//  RoutineListView.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData
import TipKit

struct RoutineListView: View {
    // Data Models
    @Environment(\.modelContext) var modelContext
    @Query var routines: [Routine]
    @State var newRoutine: Routine?
    @State var routineToEdit: Routine?
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    // Presentation Logic
    @State private var addRoutineIsPresented = false
    @State private var settingsIsPresented = false
    @State private var resetAlertIsPresented = false
    @State private var showAllRoutines = false
    @State private var showRoutineDetails = false
    @State private var routinesAreHidden = false
    @State private var addIsPressed = false
    @State private var addButtonIsPresented = true
    @State private var editRoutineIsPresented = false
    @State private var navPath: [UUID] = []
    
    // Layout Properties
    private let backgroundGradient = Gradient(colors: [.accentColor.opacity(0.28), Color(.systemBackground)])
    private let resetRoutinesTip = ResetRoutinesTip()
    @StateObject private var localeObserver = LocaleObserver()
    
    private var today: String {
        DateUtility.displayName(for: DateUtility.todayWeekday())
    }

    var body: some View {
        ZStack {
            // Ensure the rest of the screen uses the system background so the gradient only shows at the top
            Color(.systemBackground)
                .ignoresSafeArea()
            TopBackgroundGradient(color: .purple, height: 320)
            
            NavigationStack(path: $navPath) {
                Group {
                    if routines.isEmpty {
                        Text("No Routines")
                            .foregroundStyle(.secondary)
                            .accessibilityLabel(Text("No routines"))
                    } else {
                        RoutineListContent(showAllRoutines: $showAllRoutines, routineToEdit: $routineToEdit, showRoutineDetails: $showRoutineDetails, deleteRoutine: deleteRoutine)
                        .onChange(of: routineToEdit) { _, newValue in
                            if newValue != nil {
                                editRoutineIsPresented = true
                            }
                        }
                        .onAppear() {
                            Task {
                                do {
                                    try await routineManager.checkRoutinesCompletion(routines)
                                } catch {
                                    print("Error checking routine completion: \(error.localizedDescription)")
                                }
                            }
                            // Refresh locale settings when view appears
                            localeObserver.refresh()
                            // Defer showing the add button to when this view is fully visible again.
                        }
                        .onReceive(localeObserver.$localeIdentifier) { _ in
                            // Refresh today's day name when locale changes
                        }
                        .onReceive(localeObserver.$firstWeekday) { _ in
                            // Refresh when week start changes
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Donate", systemImage: "gear", action: { settingsIsPresented = true })
                            .accessibilityLabel(Text("Settings"))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset Routines", systemImage: "arrow.circlepath", action: { resetAlertIsPresented = true })
                            .popoverTip(resetRoutinesTip)
                            .onTapGesture {
                                resetRoutinesTip.invalidate(reason: .actionPerformed)
                            }
                            .alert("Reset Routines to Incomplete?", isPresented: $resetAlertIsPresented) {
                                Button("Reset", role: .destructive, action: resetRoutines)
                                Button("Cancel", role: .cancel, action: { resetAlertIsPresented = false })
                            }
                            .accessibilityLabel(Text("Reset routines"))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit", systemImage: "pencil") {
                            // Update list filter immediately without animating the entire list
                            showAllRoutines.toggle()
                            // Animate the day pickers in a separate transaction so they fade/slide
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.24)) {
                                    showRoutineDetails.toggle()
                                }
                            }
                        }
                        .accessibilityLabel(Text(showAllRoutines ? "Show only today" : "Show all routines and edit"))
                    }
                }
                .navigationTitle(showAllRoutines ? "All Routines" : "Routines")
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackground(Color.clear, for: .navigationBar)
                .navigationDestination(for: UUID.self) { id in
                    if let routine = routines.first(where: { $0.id == id }) {
                        RoutineDetailView(routine: routine)
                    } else {
                        Text("Routine Not Found")
                    }
                }
                .onChange(of: navPath) { _, newPath in
                    // Fade in on pop commit; hide immediately on push
                    if newPath.isEmpty {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            addButtonIsPresented = true
                        }
                    } else {
                        addButtonIsPresented = false
                    }
                }
                .sheet(isPresented: $settingsIsPresented) {
                    SettingsSheet(isPresented: $settingsIsPresented)
                }
                .sheet(isPresented: $addRoutineIsPresented) {
                    AddRoutineSheet(
                        newRoutine: $newRoutine,
                        isPresented: $addRoutineIsPresented,
                        modelContext: modelContext
                    )
                }
                .sheet(isPresented: $editRoutineIsPresented, onDismiss: { routineToEdit = nil }) {
                    if let routine = routineToEdit {
                        EditRoutineSheet(
                            routine: routine, 
                            isPresented: $editRoutineIsPresented
                        )
                    } else {
                        Text("No Routine Selected")
                    }
                }
            }
            // No overlay: keep only the gradient behind all UI
            if addButtonIsPresented {
                FloatingAddButton(isPressed: $addIsPressed, action: addRoutine)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Helper Methods
    
    private func resetRoutines() {
        Task {
            do {
                try await routineManager.resetRoutines(routines)
            } catch {
                print("Error resetting routines: \(error.localizedDescription)")
            }
        }
    }
    
    private func addRoutine() {
        addRoutineIsPresented = true
        let routine = Routine()
        modelContext.insert(routine)
        newRoutine = routine
    }
    
    private func deleteRoutine(_ routinesToDelete: [Routine]) {
        Task {
            do {
                try await routineManager.deleteRoutines(routinesToDelete)
            } catch {
                print("Error deleting routines: \(error.localizedDescription)")
            }
        }
    }
}

// Sheet subviews moved to separate files for modularity
