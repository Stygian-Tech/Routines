//
//  EditRoutineView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI
import SwiftData
import SFSymbolsPicker

struct EditRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Bindable private var routine: Routine
    @State private var tempRoutine: Routine
   
    private let circleButtonSize = 45.5
    private var onDismiss: (Routine) -> Void
    private var onSave: (Routine) -> Void
    
    @State private var symbolPickerIsPresented = false
    @State private var tempSymbol: String
    @State private var editingStepId: UUID? = nil
    @State private var stepToEdit: Step? = nil
    @State private var showingAddStepSheet = false
    
    private var tempColor: Color {
        get {
            return tempRoutine.getIconColor()
        }
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var daySynchronizer: RoutineDaySynchronizer {
        RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    /// Sorted steps for display
    private var sortedSteps: [Step] {
        (routine.steps ?? []).sorted(by: { $0.order < $1.order })
    }
    
    /// Days that cannot be removed because at least one step has only that day scheduled.
    /// Removing such a day would leave the step with zero days (orphaned).
    private var daysRequiredBySteps: Set<Weekday> {
        guard let steps = routine.steps else { return [] }
        var lockedDays = Set<Weekday>()
        for step in steps {
            // If step has only one day, that day is locked
            if step.days.count == 1, let onlyDay = step.days.first {
                lockedDays.insert(onlyDay)
            }
        }
        return lockedDays
    }
    
    init(routine: Routine, onDismiss: @escaping (Routine) -> Void, onSave: @escaping (Routine) -> Void) {
        self.routine = routine
        self.onDismiss = onDismiss
        self.onSave = onSave
        _tempRoutine = State(initialValue: routine.copy())
        _tempSymbol = State(initialValue: routine.iconSymbol)
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Routine Name", text: $tempRoutine.name)
            }
            Section("Time & Days") {
                DatePicker("Time", selection: $tempRoutine.time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .accessibilityLabel(Text("Routine time"))
                EditDaysView(
                    days: Binding(
                        get: { tempRoutine.days },
                        set: { newDays in
                            let oldDays = Set(tempRoutine.days)
                            let newDaysSet = Set(newDays)
                            let removedDays = oldDays.subtracting(newDaysSet)
                            let addedDays = newDaysSet.subtracting(oldDays)
                            
                            tempRoutine.days = newDays
                            
                            // For added days: just add to routine (don't cascade to steps)
                            if !addedDays.isEmpty {
                                var routineDays = routine.days
                                for addedDay in addedDays {
                                    if !routineDays.contains(addedDay) {
                                        routineDays.append(addedDay)
                                    }
                                }
                                routine.days = routineDays.sorted()
                            }
                            
                            // For removed days: cascade removal to steps
                            if !removedDays.isEmpty {
                                for removedDay in removedDays {
                                    _ = daySynchronizer.cascadeRemoveDayFromRoutine(removedDay, routine: routine)
                                }
                                // Update tempRoutine to reflect final routine days (may have been prevented from removing if it would orphan a step)
                                tempRoutine.days = routine.days
                            }
                        }
                    ),
                    iconColor: tempColor,
                    daysRequiredByChildren: daysRequiredBySteps,
                    onLongPress: { weekday in
                        // Add this day to all steps
                        addDayToAllSteps(weekday)
                    }
                )
                .padding(.vertical, 3)
            }
            Section("Icon") {
                HStack {
                    Spacer()
                    Circle()
                        .fill(tempRoutine.getIconColor())
                        .frame(width: 80)
                        .overlay(
                            Image(systemName: tempRoutine.iconSymbol)
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        )
                        .accessibilityHidden(true)
                    Spacer()
                }
                HStack {
                    Text("Color")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SystemColors.allCases, id: \.self) { color in
                                Button(action: {
                                    tempRoutine.iconColor = color.rawValue
                                }) {
                                    Circle()
                                        .fill(color.color)
                                }
                                .frame(width: circleButtonSize)
                                .accessibilityLabel(Text("Color \(String(describing: color.rawValue.dropFirst()))"))
                                .accessibilityHint(Text("Sets the routine color"))
                            }
                        }
                    }
                }
                HStack {
                    Text("Symbol")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        symbolPickerIsPresented = true
                    }, label: {
                        Image(systemName: tempRoutine.iconSymbol)
                            .foregroundStyle(tempRoutine.getIconColor())
                    })
                    .accessibilityLabel(Text("Choose symbol"))
                }
//                Text("Symbol")
//                    .font(.headline)
//                ForEach(IconLists.allCases, id: \.self) { list in
//                    HStack {
//                        Text(list.rawValue)
//                            .font(.caption)
//                            .frame(width: 1.5 * circleButtonSize, height: circleButtonSize, alignment: .leading)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                ForEach(list.iconList, id: \.self) { icon in
//                                    Button(action: {
//                                        tempRoutine.iconSymbol = icon
//                                    }) {
//                                        Circle()
//                                            .fill(.gray)
//                                            .frame(width: circleButtonSize)
//                                            .overlay(
//                                                Image(systemName: icon)
//                                                    .foregroundColor(.white)
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                   }
//                }
            }
            Section("Steps") {
                ForEach(sortedSteps, id: \.id) { step in
                    EditableStepRowView(
                        routine: routine,
                        step: step,
                        editingStepId: $editingStepId,
                        tempRoutineDays: $tempRoutine.days,
                        routineColor: tempColor,
                        onEdit: {
                            stepToEdit = step
                        }
                    )
                }
                .onMove(perform: moveSteps)
                .onDelete(perform: deleteSteps)
                
                Button(action: {
                    showingAddStepSheet = true
                }) {
                    Label("Add Step", systemImage: "plus.circle")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    onDismiss(tempRoutine)
                }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    onSave(tempRoutine)
                }) {
                    Text("Done")
                }
            }
        }
        .sheet(isPresented: $symbolPickerIsPresented) {
            SymbolsPicker(selection: $tempSymbol, title: "Select Symbol", autoDismiss: true) {
                Text("Done")
            }
            .onDisappear(perform: {
                tempRoutine.iconSymbol = tempSymbol
            })
        }
        .sheet(item: $stepToEdit) { step in
            EditStepSheet(
                step: step,
                routine: routine
            )
        }
        .sheet(isPresented: $showingAddStepSheet) {
            AddStepSheet(
                routine: routine,
                isPresented: $showingAddStepSheet
            )
        }
    }
    
    // MARK: - Step Management
    
    /// Adds a day to all steps in the routine
    private func addDayToAllSteps(_ day: Weekday) {
        guard let steps = routine.steps else { return }
        
        Task {
            do {
                // Ensure the day is in the routine's schedule first
                if !routine.days.contains(day) {
                    var routineDays = routine.days
                    routineDays.append(day)
                    routine.days = routineDays.sorted()
                }
                
                // Add day to all steps that don't already have it
                for step in steps {
                    if !step.days.contains(day) {
                        daySynchronizer.addDayToStep(step, day: day, routine: routine)
                    }
                }
                
                // Update tempRoutine days to match routine days
                tempRoutine.days = routine.days
                
                // Save changes
                try daySynchronizer.save()
            } catch {
                print("Error adding day to all steps: \(error.localizedDescription)")
            }
        }
    }
    
    private func moveSteps(from source: IndexSet, to destination: Int) {
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
    
    private func deleteSteps(at offsets: IndexSet) {
        let stepsToDelete = offsets.map { sortedSteps[$0] }
        
        Task {
            do {
                // Delete the steps
                try await stepManager.deleteSteps(stepsToDelete, from: routine)
                
                // Synchronize routine days after step deletion
                daySynchronizer.synchronizeRoutineDays(routine)
                try daySynchronizer.save()
                
                // Update daysRequiredBySteps computation
                try await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error deleting steps: \(error.localizedDescription)")
            }
        }
    }
}
