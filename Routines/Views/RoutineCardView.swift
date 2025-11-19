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
    @State private var animatePicker: Bool = false
    @State private var shouldRenderPicker: Bool = false
    
    private var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var stepCount: Int {
        (routine.steps ?? []).lazy.filter { $0.isToday() }.count
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
            if shouldRenderPicker {
                ZStack {
                    EditDaysView(days: $routine.days, iconColor: routineColor)
                        .opacity(animatePicker ? 1 : 0)
                        .offset(y: animatePicker ? 0 : 8)
                }
                .zIndex(1)
            }
        }
        .onAppear {
            if showDetail {
                shouldRenderPicker = true
                animatePicker = false
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        animatePicker = true
                    }
                }
            }
        }
        .onChange(of: showDetail) { _, newValue in
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
}

//#Preview {
//    RoutineCardView(routine: Routine())
//}
