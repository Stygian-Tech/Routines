//
//  EditStepSheet.swift
//  Routines
//
//  Created for iOS step editing
//

import SwiftUI
import SwiftData

struct EditStepSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var step: Step
    @Bindable var routine: Routine
    
    @State private var stepName: String = ""
    @State private var selectedDays: [Weekday] = []
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext)
    }
    
    private var daySynchronizer: RoutineDaySynchronizer {
        RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Step Name", text: $stepName)
                        .accessibilityLabel(Text("Step name"))
                }
                Section("Days") {
                    EditDaysView(
                        days: $selectedDays,
                        iconColor: routine.getIconColor(),
                        parentRoutineDays: routine.days,
                        requiresAtLeastOneDay: true
                    )
                    .padding(.vertical, 3)
                }
            }
            .navigationTitle("Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveStep()
                    }
                    .disabled(stepName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedDays.isEmpty)
                }
            }
            .onAppear {
                stepName = step.name
                selectedDays = step.days
            }
        }
    }
    
    private func saveStep() {
        let trimmedName = stepName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            do {
                // Update step name if changed
                if trimmedName != step.name {
                    try await stepManager.updateStepName(step, name: trimmedName)
                }
                
                // Sync days with routine
                let oldDays = Set(step.days)
                let newDays = Set(selectedDays)
                
                // Add new days
                for day in newDays.subtracting(oldDays) {
                    daySynchronizer.addDayToStep(step, day: day, routine: routine)
                }
                
                // Remove old days
                for day in oldDays.subtracting(newDays) {
                    daySynchronizer.removeDayFromStep(step, day: day, routine: routine)
                }
                
                try daySynchronizer.save()
                try await routineManager.checkRoutineCompletion(routine)
                dismiss()
            } catch {
                print("Error saving step: \(error.localizedDescription)")
            }
        }
    }
}

