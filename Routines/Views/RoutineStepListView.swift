//
//  RoutineStepListView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct RoutineStepListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var routine: Routine
    
    @State private var editRoutineViewIsPresented = false
    @State private var addStepViewIsPresented = false
    @State private var showHiddenSteps = false
    @State private var addButtonIsPresented = false
    @State private var addIsPressed = false
   
    @State private var newStepName = ""
    @State private var editingStepIndex: Int? = nil
    @State private var updatedStepName: String = ""
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext)
    }
    
    var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State var stepDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        
            ZStack {
                // Make the base background the system background, overlay with a top-only gradient like Step view
                Color(.systemBackground)
                    .ignoresSafeArea()
                TopBackgroundGradient(color: routineColor, height: 280)
                
                VStack {
                    StepListView(
                        routine: routine,
                        showHiddenSteps: $showHiddenSteps,
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
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    showHiddenSteps.toggle()
                                }
                            }) {
                                Image(systemName: showHiddenSteps ? "eye" : "eye.slash")
                                    .accessibilityHidden(true)
                            }
                            .accessibilityLabel(Text(showHiddenSteps ? "Show only today" : "Show all days"))
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
                try await routineManager.updateRoutine(
                    routine,
                    name: tempRoutine.name,
                    time: tempRoutine.time,
                    iconColor: tempRoutine.iconColor,
                    iconSymbol: tempRoutine.iconSymbol,
                    days: tempRoutine.days
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
                await routineManager.checkRoutineCompletion(routine)
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

        withAnimation {
            Task {
                do {
                    _ = try await stepManager.createStep(
                        name: stepName,
                        routine: routine,
                        days: days
                    )
                    await routineManager.checkRoutineCompletion(routine)
                } catch {
                    print("Error adding step: \(error.localizedDescription)")
                }
            }
        }
    }

    func addQuickStep(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        withAnimation {
            Task {
                do {
                    _ = try await stepManager.createStep(
                        name: trimmedName,
                        routine: routine,
                        days: daysOfTheWeek
                    )
                    await routineManager.checkRoutineCompletion(routine)
                } catch {
                    print("Error adding quick step: \(error.localizedDescription)")
                }
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
