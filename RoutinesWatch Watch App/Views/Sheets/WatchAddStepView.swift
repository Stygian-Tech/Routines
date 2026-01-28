//
//  WatchAddStepView.swift
//  RoutinesWatch
//
//  Created for watchOS step creation
//

import SwiftUI
import SwiftData

struct WatchAddStepView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Bindable var routine: Routine
    @Binding var isPresented: Bool
    @State private var stepName: String = ""
    @State private var selectedDays: [Weekday] = []
    @FocusState private var isTextFieldFocused: Bool
    
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
                        addStep()
                    }) {
                        Label("Add Step", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(routine.getIconColor())
                    .disabled(stepName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedDays.isEmpty)
                    .accessibilityLabel("Add step")
                }
                .padding()
            }
            .navigationTitle("Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                // Initialize selected days to match routine days
                selectedDays = routine.days
                isTextFieldFocused = true
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

