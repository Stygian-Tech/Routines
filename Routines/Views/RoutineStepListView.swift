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
        routine.name = tempRoutine.name
        routine.time = tempRoutine.time
        routine.iconSymbol = tempRoutine.iconSymbol
        routine.iconColor = tempRoutine.iconColor
        routine.days = tempRoutine.days
        modelContext.delete(tempRoutine)
        editRoutineViewIsPresented = false
    }
    
    func deleteStep(_ indexSet: IndexSet) {
        var tempSteps = routine.steps ?? []
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
            let newStep = Step(name: newStepName, routine: routine, order: (routine.steps?.count ?? 0), days: stepDays)
            newStepName = ""
            stepDays = daysOfTheWeek
            modelContext.insert(newStep)
            if routine.steps == nil {
                routine.steps = []
            }
            routine.steps?.append(newStep)
        }
        
        save()
        routine.checkRoutineCompletion()
    }

    func addQuickStep(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        withAnimation {
            let newStep = Step(name: trimmedName, routine: routine, order: (routine.steps?.count ?? 0), days: daysOfTheWeek)
            modelContext.insert(newStep)
            if routine.steps == nil {
                routine.steps = []
            }
            routine.steps?.append(newStep)
        }
        save()
        routine.checkRoutineCompletion()
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        var tempSteps = routine.steps ?? []
        tempSteps = tempSteps.sorted(by: { $0.order < $1.order })
        tempSteps.move(fromOffsets: source, toOffset: destination)

        for (index, step) in tempSteps.enumerated() {
            step.order = index
        }

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
