//
//  RoutineStepListView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct RoutineStepListView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var routine: Routine
    
    var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    @State private var editRoutineViewIsPresented = false
    @State private var addStepViewIsPresented = false
    @State private var newStepName = ""
    @State private var editingStepIndex: Int? = nil
    @State private var updatedStepName: String = ""
    
    @State private var showHiddenSteps = false
    @State private var addButtonIsPresented = false
    @State private var addIsPressed = false
    
    var daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State var stepDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        routineInfoHeader
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
                floatingButton
            }
        }
    }// body
    
    // MARK: Components
    var routineInfoHeader: some View {
        HStack {
            Image(systemName: "clock")
            Text(routine.timeToString())
            Spacer()
        } // HStack
        .padding(.leading)
    }
    
    var stepList: some View {
        List {
            ForEach(sortedSteps, id: \.id) { step in
                if step.isToday() || showHiddenSteps {
                    stepRow(for: step)
                } // if
            } // ForEach
            .onMove(perform: moveItem)
            .onDelete(perform: deleteStep)

            // Quick Add Button
            HStack {
                TextField("Quick Add", text: $newStepName)
                    .onSubmit {
                        addStep()
                    } // onSubmit
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(routine.getIconColor())
                    .onTapGesture {
                        addStep()
                    } // onTapGesture
                    .font(.title3)
            } // HStack
        } // List
    }
    
    var sortedSteps: [Step] {
        routine.steps.sorted(by: { $0.order < $1.order })
    }
    
    func stepRow(for step: Step) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    if step.status != .complete {
                        step.status = .complete
                    } else {
                        step.status = .incomplete
                    }
                    routine.checkRoutineCompletion()
                }) {
                    Image(systemName: step.status.icon)
                        .foregroundStyle(routine.getIconColor())
                        .contentShape(Rectangle())
                }
                .font(.title3)
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    LongPressGesture()
                        .onEnded {_ in
                            if step.status != .skipped {
                                step.status = .skipped
                            } else {
                                step.status = .incomplete
                            }
                            routine.checkRoutineCompletion()
                        }
                )
                if editingStepIndex == step.order {
                    TextField(step.name, text: $updatedStepName)
                        .onSubmit {
                            guard updatedStepName.isEmpty else {
                                step.name = updatedStepName
                                return
                            }
                            editingStepIndex = nil
                            save()
                        }
                } else {
                    Text(step.name)
                        .onTapGesture {
                            updatedStepName = step.name
                            editingStepIndex = step.order
                        }
                }
            }
            if showHiddenSteps {
                if let index = routine.steps.firstIndex(where: {$0.id == step.id }) {
                    EditDaysView(days: $routine.steps[index].days, iconColor: routineColor)
                        .transition(.move(edge: .bottom).combined(with: .opacity)) // Slide up & fade
                        .animation(.easeInOut(duration: 0.3), value: showHiddenSteps) // Smooth animation
                }
            }
        }
    }
    
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
    
    var floatingButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Circle()
                    .fill(addIsPressed ? routine.getIconColor().opacity(0.7) : routine.getIconColor())
                    .frame(width: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.title2)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    addIsPressed = true
                                } // withAnimation
                            } // onChanged
                            .onEnded { _ in
                                withAnimation {
                                    addIsPressed = false
                                    addStepViewIsPresented = true
                                } // withAnimation
                            } // onEnded
                    )
            } // HStack
            .padding(.trailing, 30)
            .padding(.bottom, 20)
        } // VStack
    } // floatingButton
    
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
