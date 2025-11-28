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
    @Bindable var routine: Routine
    @Binding var isPresented: Bool
    @State private var stepName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext)
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
                    
                    Button(action: {
                        addStep()
                    }) {
                        Label("Add Step", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(routine.getIconColor())
                    .disabled(stepName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                isTextFieldFocused = true
            }
        }
    }
    
    private func addStep() {
        let trimmedName = stepName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            do {
                _ = try await stepManager.createStep(
                    name: trimmedName,
                    routine: routine,
                    days: routine.days
                )
                try await routineManager.checkRoutineCompletion(routine)
                isPresented = false
            } catch {
                print("Error adding step: \(error.localizedDescription)")
            }
        }
    }
}

