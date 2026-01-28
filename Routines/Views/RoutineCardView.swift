//
//  RoutineCardView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct RoutineCardView: View {
    @Bindable var routine: Routine
    
    private var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var stepCount: Int {
        (routine.steps ?? []).lazy.filter { $0.isToday() }.count
    }
    
    var body: some View {
        VStack {
            HStack {
                RoutineIconView(routine: routine)
                Spacer()
            }
            .padding(.bottom, 4)
            HStack(alignment: .center) {
                let totalStepsToday = stepCount
                if routine.status == .incomplete && totalStepsToday > 1 {
                    RingProgressView(for: routine)
                        .frame(width: 18, height: 18)
                        .padding(.leading, 6)
                        .padding(.bottom, 1)
                        .layoutPriority(0) // Resizes the ProgressView to avoid text wrapping
                } else {
                    CompletionIconView(for: routine)
                }
                Text(routine.name)
                    .font(.headline)
                    .layoutPriority(1) // Prevents the text from wrapping by resizing the ProgressView
                Spacer()
            }
            .padding(.bottom, 4)
            HStack {
                Image(systemName: "list.bullet")
                    .accessibilityHidden(true)
                Text("\(stepCount) step\(stepCount != 1 ? "s" : "") today")
                Spacer()
                Text("\(routine.timeToString())")
                Image(systemName: "clock")
                    .accessibilityHidden(true)
            }
            .padding(.leading)
            .padding(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Opens routine"))
    }
}

//#Preview {
//    RoutineCardView(routine: Routine())
//}
