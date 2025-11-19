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
    @State private var animatePicker: Bool = false
    @State private var shouldRenderPicker: Bool = false
    
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
                .accessibilityLabel(Text(step.status == .complete ? "Mark incomplete" : "Mark complete"))
                .accessibilityValue(Text(step.status == .complete ? "Complete" : (step.status == .skipped ? "Skipped" : "Incomplete")))
                .accessibilityHint(Text("Toggles completion state"))
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
                        EditDaysView(days: Binding(
                            get: { steps[index].days },
                            set: { steps[index].days = $0 }
                        ), iconColor: routine.getIconColor())
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
