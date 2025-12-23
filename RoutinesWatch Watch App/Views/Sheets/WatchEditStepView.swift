//
//  WatchEditStepView.swift
//  RoutinesWatch
//
//  Created for watchOS step editing
//

import SwiftUI
import SwiftData

struct WatchEditStepView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var step: Step
    @Bindable var routine: Routine
    @Binding var isPresented: Bool
    
    @State private var stepName: String = ""
    @State private var selectedDays: [Weekday] = []
    @FocusState private var isTextFieldFocused: Bool
    
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
            ScrollView {
                VStack(spacing: 12) {
                    TextField("Step Name", text: $stepName)
                        .textInputAutocapitalization(.words)
                        .focused($isTextFieldFocused)
                        .padding()
                        .background(Color(.gray).opacity(0.03))
                        .cornerRadius(8)
                    
                    // Days selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        WatchEditDaysView(
                            days: $selectedDays,
                            iconColor: routine.getIconColor(),
                            parentRoutineDays: routine.days,
                            requiresAtLeastOneDay: true
                        )
                    }
                    
                    Button(action: {
                        saveStep()
                    }) {
                        Label("Save Step", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(routine.getIconColor())
                    .disabled(stepName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedDays.isEmpty)
                    .accessibilityLabel("Save step")
                }
                .padding()
            }
            .navigationTitle("Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
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
                isPresented = false
            } catch {
                print("Error saving step: \(error.localizedDescription)")
            }
        }
    }
}
