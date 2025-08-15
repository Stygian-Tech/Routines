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
    @Bindable var routine: Routine
    @Bindable var step: Step
    @State private var updatedStepName: String = ""
    @Binding var editingStepIndex: Int?
    @Binding var showHiddenSteps: Bool
    
    var body: some View {
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
                .contextMenu {
                    Button(action: { step.status = .skipped }) {
                        Label("Skip '\(step.name)'", systemImage: "circle.slash")
                    }
                    Button(action: { step.status = .complete }) {
                        Label("Complete '\(step.name)'", systemImage: "checkmark.circle")
                    }
                    //TODO: destructive action is not deleting step
                    Button(role: .destructive, action: { modelContext.delete(step) }, label: { Label("Delete \(step.name)", systemImage: "trash") })
                }
                if editingStepIndex == step.order {
                    TextField(step.name, text: $updatedStepName)
                        .onSubmit {
                            guard !updatedStepName.isEmpty else {
                                editingStepIndex = nil
                                return
                            }
                            step.name = updatedStepName
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
            .animation(.none, value: showHiddenSteps)
            if showHiddenSteps {
                if let index = routine.steps.firstIndex(where: {$0.id == step.id }) {
                    ZStack {
                        EditDaysView(days: $routine.steps[index].days, iconColor: routine.getIconColor())
                            .transition(.move(edge: .top))
                            .transition(.opacity)
                        
                    }
                    .animation(.easeInOut(duration: 0.2), value: showHiddenSteps)
                }
            }
        }
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error Saving: \(error.localizedDescription)")
        }
    }
    
    private func skipStep() {
        
    }
}
