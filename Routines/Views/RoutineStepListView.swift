//
//  RoutineStepListView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

// MARK: - RoutineStepListView

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
    
    var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State var stepDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        RoutineInfoHeaderView(routine: routine)
        ZStack {
            NavigationStack {
                StepListView(
                    routine: routine,
                    showHiddenSteps: $showHiddenSteps,
                    editingStepIndex: $editingStepIndex,
                    moveItem: moveItem,
                    deleteStep: deleteStep,
                    addStep: addStep)
            }
            .navigationTitle(routine.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // TODO: Share Sheet
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        editRoutineViewIsPresented = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showHiddenSteps.toggle() }) {
                        Image(systemName: showHiddenSteps ? "eye" : "eye.slash")
                    }
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
            .onAppear() {
                addButtonIsPresented = true
            }
            .onDisappear() {
                addButtonIsPresented = false
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
        routine.name = tempRoutine.name
        routine.time = tempRoutine.time
        routine.iconSymbol = tempRoutine.iconSymbol
        routine.iconColor = tempRoutine.iconColor
        routine.days = tempRoutine.days
        modelContext.delete(tempRoutine)
        editRoutineViewIsPresented = false
    }
    
    func deleteStep(_ indexSet: IndexSet) {
        var tempSteps = routine.steps
        tempSteps = tempSteps.sorted(by: { $0.order < $1.order })

        for index in indexSet.map({ $0 }) {
            tempSteps.remove(at: index)
        }

        for (index, step) in tempSteps.enumerated() {
            step.order = index
        }

        routine.steps = tempSteps
        save()
        routine.checkRoutineCompletion()
    }

    func addStep() {
        guard !newStepName.isEmpty else { return }

        withAnimation {
            let newStep = Step(name: newStepName, routine: routine, order: routine.steps.count, days: stepDays)
            newStepName = ""
            stepDays = daysOfTheWeek
            modelContext.insert(newStep)
            routine.steps.append(newStep)
        }
        
        save()
        routine.checkRoutineCompletion()
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        var tempSteps = routine.steps
        tempSteps = tempSteps.sorted(by: { $0.order < $1.order })
        tempSteps.move(fromOffsets: source, toOffset: destination)

        for (index, step) in tempSteps.enumerated() {
            step.order = index
        } // for

        routine.steps = tempSteps
        save()

    }

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error Saving: \(error.localizedDescription)")
        }
    }
}
