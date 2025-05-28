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
    var onAdd: () -> Void
    
    var body: some View {
        HStack {
            TextField("Quick Add", text: $newStepName)
                .onSubmit {
                    onAdd()
                }
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(routine.getIconColor())
                .onTapGesture {
                    onAdd()
                }
                .font(.title3)
        }
    }
} 