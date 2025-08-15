//
//  StepListView.swift
//  Routines
//
//  Created by Sam Clemente on 5/27/25.
//

import SwiftUI

struct StepListView: View {
    @Bindable var routine: Routine
    @State var newStepName: String = ""
    @Binding var showHiddenSteps: Bool
    @Binding var editingStepIndex: Int?
    
    var moveItem: (IndexSet, Int) -> Void
    var deleteStep: (IndexSet) -> Void
    var addStep: (String) -> Void

    var body: some View {
        List {
            ForEach(Array(routine.steps.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, step in
                if step.isToday() || showHiddenSteps {
                    StepRowView(
                        routine: routine,
                        step: step,
                        editingStepIndex: $editingStepIndex,
                        showHiddenSteps: $showHiddenSteps
                    )
                }
            }
            .onMove(perform: moveItem)
            .onDelete(perform: deleteStep)

            QuickAddStepView(
                newStepName: $newStepName,
                routine: routine,
                onAdd: { name in
                    addStep(name)
                }
            )
        }
    }
}
