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
    @Binding var showDetail: Bool
    
    private var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var stepCount: Int {
        routine.steps.lazy.filter { $0.isToday() }.count
    }
    
    init(routine: Routine, showDetail: Binding<Bool>) {
        self.routine = routine
        _showDetail = showDetail
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    RoutineIconView(routine: routine)
                    Spacer()
                }
                .padding(.bottom, 4)
                HStack {
                    let totalStepsToday = stepCount
                    if routine.status == .incomplete && totalStepsToday > 1 {
                        let progress = (totalStepsToday == 0) ? 0 : Double(routine.finishedStepCount) / Double(totalStepsToday)
                        RingProgressView(progress: progress, color: routine.getIconColor(), lineWidth: 2)
                            .frame(width: 18, height: 18)
                            .padding(.leading, 6)
                            .padding(.bottom, 1)
                            .layoutPriority(0) // Resizes the ProgressView to avoid text wrapping
                            .accessibilityLabel(Text("Progress"))
                            .accessibilityValue(Text("\(routine.finishedStepCount) of \(totalStepsToday) steps complete"))
                    } else {
                        Image(systemName: "checkmark.circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(routine.status.icon.iconColor2 ?? routine.status.icon.iconColor1, routine.status.icon.iconColor1)
                            .padding(.leading, 3)
                            .accessibilityHidden(true)
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
            .animation(.none, value: showDetail)
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text("Opens routine"))
            if showDetail == true {
                ZStack {
                    EditDaysView(days: $routine.days, iconColor: routineColor)
                        .transition(.move(edge: .top))
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.2), value: showDetail)
            }
        }
    }
}

//#Preview {
//    RoutineCardView(routine: Routine())
//}
