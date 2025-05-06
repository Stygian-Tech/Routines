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
                stepList
            } // NavigationStack
            .navigationTitle(routine.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // TODO: Share Sheet
                } // ToolbarItem
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        editRoutineViewIsPresented = true
                    }) {
                        Image(systemName: "pencil")
                    } // Button
                } // ToolbarItem
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showHiddenSteps.toggle()
                        }
                    }) {
                        withAnimation {
                            Image(systemName: showHiddenSteps ? "eye" : "eye.slash")
                        } // withAnimation
                    } // Button
                } // ToolbarItem
            } // toolbar
            .sheet(isPresented: $addStepViewIsPresented) {
                addStepSheet
            } // sheet
            .sheet(isPresented: $editRoutineViewIsPresented) {
                NavigationStack {
                    EditRoutineView(routine: routine, onDismiss: { tempRoutine in
                        dismissEditRoutine(tempRoutine)
                    }, onSave: { tempRoutine in
                        saveRoutine(tempRoutine)
                    })
                    .navigationTitle("Edit \(routine.name)")
                } // NavigationStack
            } // sheet
            .onAppear() {
                addButtonIsPresented = true
            } // onAppear
            .onDisappear() {
                addButtonIsPresented = false
            } // onDisappear
            
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
    }// body
    
    // MARK: Step List
    
    var stepList: some View {
        List {
            ForEach(Array(routine.steps.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, step in
                if step.isToday() || showHiddenSteps {
                    StepRowView(
                        routine: routine,
                        step: step,
                        editingStepIndex: $editingStepIndex,
                        showHiddenSteps: $showHiddenSteps
                    )
                }
            }
            .onMove(perform: moveItem)
            .onDelete(perform: deleteStep)

            // Quick Add Button
            QuickAddStepView(
                newStepName: $newStepName,
                routine: routine,
                onAdd: addStep
            )
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
                        } // Button
                    } // ToolbarItem
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            addStep()
                            addStepViewIsPresented = false
                        }) {
                            Text("Done")
                        } // Button
                    } // ToolbarItem
                } // toolbar
        } // NavigationView
    } // addStepSheet
    
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
            print("Deleting \(tempSteps[index].name) from position \(tempSteps[index].order)")
            tempSteps.remove(at: index)
        } // for

        for (index, step) in tempSteps.enumerated() {
            step.order = index
        } // for

        routine.steps = tempSteps
        save()
        routine.checkRoutineCompletion()
    } // deleteStep

    func addStep() {
        guard !newStepName.isEmpty else { return }

        withAnimation {
            let newStep = Step(name: newStepName, routine: routine, order: routine.steps.count, days: stepDays)
            print("Adding Step: \(newStep.name) to position: \(newStep.order)")
            newStepName = ""
            stepDays = daysOfTheWeek
            modelContext.insert(newStep)
            routine.steps.append(newStep)
        } // withAnimation
        save()
        routine.checkRoutineCompletion()
    } // addStep

    func moveItem(from source: IndexSet, to destination: Int) {
        var tempSteps = routine.steps
        tempSteps = tempSteps.sorted(by: { $0.order < $1.order })
        tempSteps.move(fromOffsets: source, toOffset: destination)

        for (index, step) in tempSteps.enumerated() {
            step.order = index
        } // for

        routine.steps = tempSteps
        save()

        for step in routine.steps.sorted(by: {$0.order < $1.order }) {
            print("Step \"\(step.name)\" is at index: \(step.order)")
        } // for
        print("----------------------------")
    } // moveItem

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error Saving: \(error.localizedDescription)")
        } // do/catch
    } // save
} // RoutineStepListView
