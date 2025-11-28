//
//  RingProgressView.swift
//  Routines
//
//  Created by AI on 2025-08-18.
//

import SwiftUI

struct RingProgressView: View {
	var routine: Routine
	var lineWidth: CGFloat = 2
	
	private var totalStepsToday: Int {
		(routine.steps ?? []).filter { $0.isToday() }.count
	}
	
	private var progress: Double {
		(totalStepsToday == 0) ? 0 : Double(routine.finishedStepCount) / Double(totalStepsToday)
	}
	
	private var color: Color {
		routine.getIconColor()
	}
	
	var body: some View {
		ZStack {
			Circle()
				.stroke(color.opacity(0.2), lineWidth: lineWidth)
			Circle()
				.trim(from: 0, to: max(0, min(1, progress)))
				.stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
				.rotationEffect(.degrees(-90))
		}
		.accessibilityLabel(Text("Progress"))
		.accessibilityValue(Text("\(routine.finishedStepCount) of \(totalStepsToday) steps complete"))
	}
}


