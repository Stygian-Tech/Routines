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
    @State private var routineDays: [String]
    
    private var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var stepCount: Int {
        if routine.steps.count == 0 {
            return 0
        } else {
            var tempCount = 0
            for step in routine.steps {
                if step.isToday() {
                    tempCount += 1
                }
            }
            return tempCount
        }
    }
    
    init(routine: Routine, showDetail: Binding<Bool>) {
        self.routine = routine
        _showDetail = showDetail
        _routineDays = State(initialValue: routine.days)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack{
                    VStack {
                        HStack {
                            RoutineIconView(routine: routine)
                            Spacer()
                        }
                        HStack {
                            Text(routine.name)
                                .font(.headline)
                                .layoutPriority(1) // Prevents the text from wrapping by resizing the ProgressView
                            if routine.status == .incomplete && stepCount > 1 {
                                ProgressView(value: (stepCount == 0) ? 0 : Double(routine.finishedStepCount) / Double(stepCount))
                                    .padding(.leading)
                                    .tint(routine.getIconColor())
                                    .layoutPriority(0) // Resizes the ProgressView to avoid text wrapping
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(routine.status.icon.iconColor2 ?? routine.status.icon.iconColor1, routine.status.icon.iconColor1)
                                    .padding(.bottom, 1) // ProgressView is a little taller than Image so this prevents the card from changing size when you reset the routine to incomplete
                            }
                            Spacer()
                        }
                    }
                }
                HStack {
                    Image(systemName: "list.bullet")
                    Text("\(stepCount) step\(stepCount != 1 ? "s" : "") today")
                    Spacer()
                    Text("\(routine.timeToString())")
                    Image(systemName: "clock")
                }
                .padding(.leading)
                .padding(.trailing)
            }
            .animation(.none, value: showDetail)
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
