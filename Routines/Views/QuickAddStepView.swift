//
//  QuickAddStepView.swift
//  Routines
//
//  Created by Sam Clemente on 4/8/25.
//

import SwiftUI

struct QuickAddStepView: View {
    @Binding var newStepName: String
    let routine: Routine
    var onAdd: (String) -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Quick Add", text: $newStepName)
                .focused($isFocused)
                .submitLabel(.return)
                .onSubmit {
                    let name = newStepName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    onAdd(name)
                    newStepName = ""
                    isFocused = true
                }
            Spacer()
            //TODO: Button is taking up too much of view
            Button(action: {
                let name = newStepName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                onAdd(name)
                newStepName = ""
                isFocused = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(routine.getIconColor())
                    .font(.title3)
            }
        }
    }
} 
