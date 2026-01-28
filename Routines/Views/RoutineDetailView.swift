//
//  RoutineDetailView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct RoutineDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Bindable var routine: Routine
    
    @State private var editRoutineViewIsPresented = false
    @State private var addStepViewIsPresented = false
    @State private var addButtonIsPresented = false
    @State private var addIsPressed = false
   
    @State private var newStepName = ""
    @State private var editingStepIndex: Int? = nil
    @State private var updatedStepName: String = ""
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var daySynchronizer: RoutineDaySynchronizer {
        RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var daysOfTheWeek: [Weekday] {
        DateUtility.allWeekdays()
    }
    @State var stepDays: [Weekday] = DateUtility.allWeekdays()
    
    var body: some View {
        
            ZStack {
                // Make the base background the system background, overlay with a top-only gradient like Step view
                Color(.systemBackground)
                    .ignoresSafeArea()
                TopBackgroundGradient(color: routineColor, height: 280)
                
                VStack {
                    StepListView(
                        routine: routine,
                        showHiddenSteps: .constant(false),
                        editingStepIndex: $editingStepIndex,
                        moveItem: moveItem,
                        deleteStep: deleteStep,
                        addStep: addQuickStep
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            // TODO: Share Sheet
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                editRoutineViewIsPresented = true
                            }) {
                                Image(systemName: "pencil")
                                    .accessibilityHidden(true)
                            }
                            .accessibilityLabel(Text("Edit routine"))
                        }
                    }
                    .sheet(isPresented: $addStepViewIsPresented) {
                        addStepSheet
                    }
                    .sheet(isPresented: $editRoutineViewIsPresented) {
                        NavigationStack {
                            EditRoutineView(routine: routine, onDismiss: { tempRoutine in
                                dismissEditRoutine(tempRoutine)
                            }, onSave: { tempRoutine in
                                saveRoutine(tempRoutine)
                            })
                            .navigationTitle("Edit \(routine.name)")
                        }
                    }
                }
                if addButtonIsPresented {
                    FloatingAddButton(
                        color: routineColor,
                        isPressed: $addIsPressed,
                        action: {
                            addStepViewIsPresented = true
                        }
                    )
                }
            }
            .navigationTitle(routine.name)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .accessibilityRespondsToUserInteraction(true)
        .onAppear() {
            addButtonIsPresented = true
        }
        .onDisappear() {
            addButtonIsPresented = false
        }
    }
    
    // MARK: Add Step Sheet
    
    var addStepSheet: some View {
        NavigationView {
            AddStepView(routine: routine, newStep: $newStepName)
                .navigationTitle("Add Step")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            addStepViewIsPresented = false
                            newStepName = ""
                        }) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            addStep()
                            addStepViewIsPresented = false
                        }) {
                            Text("Done")
                        }
                    }
                }
        }
    }
    
    // MARK: Helper Methods
    
    func dismissEditRoutine(_ tempRoutine: Routine) {
        modelContext.delete(tempRoutine)
        editRoutineViewIsPresented = false
    }
    
    func saveRoutine(_ tempRoutine: Routine) {
        Task {
            do {
                // Find days that were removed from routine
                let oldDays = Set(routine.days)
                let newDays = Set(tempRoutine.days)
                let removedDays = oldDays.subtracting(newDays)
                let addedDays = newDays.subtracting(oldDays)
                
                // Cascade removed days to steps using synchronizer
                if !removedDays.isEmpty {
                    for removedDay in removedDays {
                        _ = daySynchronizer.cascadeRemoveDayFromRoutine(removedDay, routine: routine)
                    }
                    // Explicitly save step changes
                    try modelContext.save()
                }
                
                // Add any new days to routine (don't cascade to steps)
                if !addedDays.isEmpty {
                    var routineDays = routine.days
                    for addedDay in addedDays {
                        if !routineDays.contains(addedDay) {
                            routineDays.append(addedDay)
                        }
                    }
                    routine.days = routineDays.sorted()
                }
                
                // Final synchronization: ensure routine days are superset of all step days
                daySynchronizer.synchronizeRoutineDays(routine)
                
                try await routineManager.updateRoutine(
                    routine,
                    name: tempRoutine.name,
                    time: tempRoutine.time,
                    iconColor: tempRoutine.iconColor,
                    iconSymbol: tempRoutine.iconSymbol,
                    days: routine.days
                )
                modelContext.delete(tempRoutine)
                editRoutineViewIsPresented = false
            } catch {
                print("Error updating routine: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteStep(_ indexSet: IndexSet) {
        let stepsToDelete = indexSet.map { index in
            let sortedSteps = (routine.steps ?? []).sorted(by: { $0.order < $1.order })
            return sortedSteps[index]
        }
        
        Task {
            do {
                try await stepManager.deleteSteps(stepsToDelete, from: routine)
                try await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error deleting steps: \(error.localizedDescription)")
            }
        }
    }

    func addStep() {
        guard !newStepName.isEmpty else { return }
        
        let stepName = newStepName
        newStepName = ""
        let days = stepDays
        stepDays = daysOfTheWeek

        Task {
            do {
                _ = try await stepManager.createStep(
                    name: stepName,
                    routine: routine,
                    days: days
                )
                try await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error adding step: \(error.localizedDescription)")
            }
        }
    }

    func addQuickStep(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            do {
                _ = try await stepManager.createStep(
                    name: trimmedName,
                    routine: routine,
                    days: daysOfTheWeek
                )
                try await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error adding quick step: \(error.localizedDescription)")
            }
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        Task {
            do {
                try await stepManager.moveSteps(
                    from: source,
                    to: destination,
                    in: routine
                )
            } catch {
                print("Error moving steps: \(error.localizedDescription)")
            }
        }
    }

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error Saving: \(error.localizedDescription)")
        }
    }
}

