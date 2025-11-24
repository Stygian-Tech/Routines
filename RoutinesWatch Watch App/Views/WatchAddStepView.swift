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
        
        let newStep = Step(
            name: trimmedName,
            routine: routine,
            order: (routine.steps?.count ?? 0),
            days: routine.days
        )
        
        modelContext.insert(newStep)
        if routine.steps == nil {
            routine.steps = []
        }
        routine.steps?.append(newStep)
        
        do {
            try modelContext.save()
            routine.checkRoutineCompletion()
            isPresented = false
        } catch {
            print("Error adding step: \(error.localizedDescription)")
        }
    }
}
