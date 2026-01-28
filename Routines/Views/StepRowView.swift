//
//  StepRowView.swift
//  Routines
//
//  Created by Sam Clemente on 4/8/25.
//

import SwiftUI
import SwiftData

// Model types imported from the main app
// To fix these errors, we need to bring the model definitions into scope
// Import the models properly here

struct StepRowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Bindable var routine: Routine
    @Bindable var step: Step
    @State private var updatedStepName: String = ""
    @Binding var editingStepIndex: Int?
    @Binding var showHiddenSteps: Bool
    @State private var animatePicker: Bool = false
    @State private var shouldRenderPicker: Bool = false
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var daySynchronizer: RoutineDaySynchronizer {
        RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    // Provide haptic feedback when checking off step
                    HapticFeedback.medium()
                    Task {
                        do {
                            if step.status != .complete {
                                try await stepManager.updateStepStatus(step, status: .complete)
                            } else {
                                try await stepManager.updateStepStatus(step, status: .incomplete)
                            }
                            try await routineManager.checkRoutineCompletion(routine)
                        } catch {
                            print("Error updating step status: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Image(systemName: step.status.icon)
                        .foregroundStyle(routine.getIconColor())
                        .contentShape(Rectangle())
                }
                .font(.title3)
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text(step.status == .complete ? "Mark incomplete" : "Mark complete"))
                .accessibilityValue(Text(step.status == .complete ? "Complete" : (step.status == .skipped ? "Skipped" : "Incomplete")))
                .accessibilityHint(Text("Toggles completion state"))
                .contextMenu {
                    Button(action: {
                        HapticFeedback.medium()
                        Task {
                            do {
                                try await stepManager.updateStepStatus(step, status: .skipped)
                                try await routineManager.checkRoutineCompletion(routine)
                            } catch {
                                print("Error skipping step: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Label("Skip '\(step.name)'", systemImage: "circle.slash")
                    }
                    Button(action: {
                        HapticFeedback.medium()
                        Task {
                            do {
                                try await stepManager.updateStepStatus(step, status: .complete)
                                try await routineManager.checkRoutineCompletion(routine)
                            } catch {
                                print("Error completing step: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Label("Complete '\(step.name)'", systemImage: "checkmark.circle")
                    }
                    Button(role: .destructive, action: {
                        Task {
                            do {
                                try await stepManager.deleteSteps([step], from: routine)
                                try await routineManager.checkRoutineCompletion(routine)
                            } catch {
                                print("Error deleting step: \(error.localizedDescription)")
                            }
                        }
                    }, label: { Label("Delete \(step.name)", systemImage: "trash") })
                }
                if editingStepIndex == step.order {
                    TextField(step.name, text: $updatedStepName)
                        .onSubmit {
                            guard !updatedStepName.isEmpty else {
                                editingStepIndex = nil
                                return
                            }
                            Task {
                                do {
                                    try await stepManager.updateStepName(step, name: updatedStepName)
                                    editingStepIndex = nil
                                } catch {
                                    print("Error updating step name: \(error.localizedDescription)")
                                }
                            }
                        }
                        .accessibilityLabel(Text("Edit step name"))
                } else {
                    Text(step.name)
                        .onTapGesture {
                            updatedStepName = step.name
                            editingStepIndex = step.order
                        }
                        .accessibilityLabel(Text(step.name))
                }
            }
            .animation(.none, value: showHiddenSteps)
            if showHiddenSteps || shouldRenderPicker {
                if let steps = routine.steps, let index = steps.firstIndex(where: {$0.id == step.id }) {
                    ZStack {
                        EditDaysView(
                            days: Binding(
                                get: {
                                    let originalStepDays = steps[index].days
                                    let routineDaysSet = Set(routine.days)
                                    
                                    // Filter out any days that aren't in the routine's schedule
                                    // This is a safeguard in case cascade removal didn't work
                                    var filteredStepDays = originalStepDays.filter { routineDaysSet.contains($0) }
                                    
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
                                    }
                                    for day in removedDays {
                                        daySynchronizer.removeDayFromStep(steps[index], day: day, routine: routine)
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
                            iconColor: routine.getIconColor(),
                            parentRoutineDays: routine.days,
                            requiresAtLeastOneDay: true
                        )
                        .opacity(animatePicker ? 1 : 0)
                        .offset(y: animatePicker ? 0 : 8)
                    }
                    .zIndex(1)
                }
            }
        }
        .onAppear {
            if showHiddenSteps {
                shouldRenderPicker = true
                animatePicker = false
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        animatePicker = true
                    }
                }
            }
        }
        .onChange(of: showHiddenSteps) { _, newValue in
            if newValue {
                animatePicker = false
                shouldRenderPicker = true
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        animatePicker = true
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.24)) {
                    animatePicker = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                    shouldRenderPicker = false
                }
            }
        }
    }
    
}
