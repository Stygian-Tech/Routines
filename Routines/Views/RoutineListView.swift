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
    
    // Presentation Logic
    @State private var addRoutineIsPresented = false
    @State private var settingsIsPresented = false
    @State private var resetAlertIsPresented = false
    @State private var showAllRoutines = false
    @State private var routinesAreHidden = false
    @State private var addIsPressed = false
    @State private var addButtonIsPresented = true
    @State private var editRoutineIsPresented = false
    @State private var navPath: [UUID] = []
    
    // Layout Properties
    let backgroundGradient = Gradient(colors: [.accentColor.opacity(0.28), Color(.systemBackground)])
    let resetRoutinesTip = ResetRoutinesTip()
    
    var today: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            TopBackgroundGradient(color: .purple, height: 320)
            
            NavigationStack(path: $navPath) {
                Group {
                    if routines.isEmpty {
                        Text("No Routines")
                            .foregroundStyle(.secondary)
                    } else {
                        RoutineList(showAllRoutines: $showAllRoutines, routineToEdit: $routineToEdit, deleteRoutine: deleteRoutine)
                        .onChange(of: routineToEdit) { _, newValue in
                            if newValue != nil {
                                editRoutineIsPresented = true
                            }
                        }
                        .onAppear() {
                            for routine in routines {
                                routine.checkRoutineCompletion()
                            }
                            // Defer showing the add button to when this view is fully visible again.
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Donate", systemImage: "gear", action: { settingsIsPresented = true })
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
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Show All Routines", systemImage: showAllRoutines ? "eye" : "eye.slash") {
                            withAnimation {
                                showAllRoutines.toggle()
                            }
                        }
                    }
                }
                .navigationTitle(showAllRoutines ? "All Routines" : "Routines")
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackground(Color.clear, for: .navigationBar)
                .navigationDestination(for: UUID.self) { id in
                    if let routine = routines.first(where: { $0.id == id }) {
                        RoutineStepListView(routine: routine)
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
        for routine in routines {
            routine.resetSteps()
        }
    }
    
    private func addRoutine() {
        addRoutineIsPresented = true
        let routine = Routine()
        modelContext.insert(routine)
        newRoutine = routine
    }
    
    private func deleteRoutine(_ routinesToDelete: [Routine]) {
        for routine in routinesToDelete {
            modelContext.delete(routine)
        }
    }
}

// Sheet subviews moved to separate files for modularity
