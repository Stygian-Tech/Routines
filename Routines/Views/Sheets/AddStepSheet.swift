//
//  AddStepSheet.swift
//  Routines
//
//  Created for adding steps from edit routine view
//

import SwiftUI
import SwiftData

struct AddStepSheet: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var routine: Routine
    @Binding var isPresented: Bool
    
    @State private var stepName: String = ""
    @State private var selectedDays: [Weekday] = []
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext)
    }
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
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
            .navigationTitle("Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        addStep()
                    }
                    .disabled(stepName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedDays.isEmpty)
                }
            }
            .onAppear {
                // Initialize selected days to match routine days
                selectedDays = routine.days
            }
        }
    }
    
    private func addStep() {
        let trimmedName = stepName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            do {
                // Expand routine days if step includes days outside routine
                var routineDaysModified = false
                for day in selectedDays {
                    if !routine.days.contains(day) {
                        var routineDays = routine.days
                        routineDays.append(day)
                        routine.days = routineDays.sorted()
                        routineDaysModified = true
                    }
                }
                
                // Save routine days changes if modified
                if routineDaysModified {
                    try await routineManager.updateRoutine(routine, days: routine.days)
                }
                
                _ = try await stepManager.createStep(
                    name: trimmedName,
                    routine: routine,
                    days: selectedDays
                )
                try await routineManager.checkRoutineCompletion(routine)
                isPresented = false
            } catch {
                print("Error adding step: \(error.localizedDescription)")
            }
        }
    }
}

