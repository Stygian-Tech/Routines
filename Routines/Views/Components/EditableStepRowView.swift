//
//  EditableStepRowView.swift
//  Routines
//
//  Created for editable step rows in edit mode
//

import SwiftUI
import SwiftData

struct EditableStepRowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Bindable var routine: Routine
    @Bindable var step: Step
    @Binding var editingStepId: UUID?
    @Binding var tempRoutineDays: [Weekday]
    var routineColor: Color
    @State private var updatedStepName: String = ""
    
    let onEdit: () -> Void
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var daySynchronizer: RoutineDaySynchronizer {
        RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Step name - editable inline
            if editingStepId == step.id {
                TextField("Step name", text: $updatedStepName)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        saveName()
                    }
                    .onAppear {
                        updatedStepName = step.name
                    }
                    .accessibilityLabel(Text("Edit step name"))
            } else {
                Text(step.name)
                    .onTapGesture {
                        updatedStepName = step.name
                        editingStepId = step.id
                    }
                    .accessibilityLabel(Text(step.name))
            }
            
            // Day picker - always visible in edit mode
            if let steps = routine.steps, let index = steps.firstIndex(where: { $0.id == step.id }) {
                EditDaysView(
                    days: Binding(
                        get: {
                            let originalStepDays = steps[index].days
                            // Use union of routine.days and tempRoutineDays as the valid parent schedule
                            // This ensures step picker sees both current routine days and pending tempRoutine changes
                            let validParentDays = Set(routine.days).union(Set(tempRoutineDays))
                            
                            // Filter out any days that aren't in the routine's schedule
                            var filteredStepDays = originalStepDays.filter { validParentDays.contains($0) }
                            
                            // If filtering changed the days, update the step
                            if Set(filteredStepDays) != Set(originalStepDays) {
                                filteredStepDays.sort { $0.rawValue < $1.rawValue }
                                steps[index].days = filteredStepDays
                                // Save the correction immediately
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Error saving corrected step days: \(error.localizedDescription)")
                                }
                            }
                            
                            return filteredStepDays
                        },
                        set: { newDays in
                            // Determine which day was toggled by comparing old and new
                            let oldDays = Set(steps[index].days)
                            let newDaysSet = Set(newDays)
                            
                            // Find added days
                            let addedDays = newDaysSet.subtracting(oldDays)
                            // Find removed days
                            let removedDays = oldDays.subtracting(newDaysSet)
                            
                            // Use synchronizer for proper routine-step day sync
                            for day in addedDays {
                                daySynchronizer.addDayToStep(steps[index], day: day, routine: routine)
                                // Also update tempRoutine days if step added a day not in routine
                                if !tempRoutineDays.contains(day) {
                                    var updatedTempDays = tempRoutineDays
                                    updatedTempDays.append(day)
                                    tempRoutineDays = updatedTempDays.sorted()
                                }
                            }
                            for day in removedDays {
                                daySynchronizer.removeDayFromStep(steps[index], day: day, routine: routine)
                                // Update tempRoutine days if routine was shrunk
                                if !routine.days.contains(day) && tempRoutineDays.contains(day) {
                                    var updatedTempDays = tempRoutineDays
                                    updatedTempDays.removeAll { $0 == day }
                                    tempRoutineDays = updatedTempDays.sorted()
                                }
                            }
                            
                            Task {
                                do {
                                    try daySynchronizer.save()
                                } catch {
                                    print("Error saving step days: \(error.localizedDescription)")
                                }
                            }
                        }
                    ),
                    iconColor: routineColor,
                    parentRoutineDays: tempRoutineDays,
                    requiresAtLeastOneDay: true
                )
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func saveName() {
        guard !updatedStepName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            editingStepId = nil
            return
        }
        
        let trimmedName = updatedStepName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName != step.name else {
            editingStepId = nil
            return
        }
        
        Task {
            do {
                try await stepManager.updateStepName(step, name: trimmedName)
                editingStepId = nil
            } catch {
                print("Error updating step name: \(error.localizedDescription)")
                editingStepId = nil
            }
        }
    }
}

