//
//  RingProgressView.swift
//  Routines
//
//  Created by AI on 2025-08-18.
//

import SwiftUI

struct RingProgressView: View {
	var progress: Double
	var color: Color
	var lineWidth: CGFloat = 2
	
	var body: some View {
		ZStack {
			Circle()
				.stroke(color.opacity(0.2), lineWidth: lineWidth)
			Circle()
				.trim(from: 0, to: max(0, min(1, progress)))
				.stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
				.rotationEffect(.degrees(-90))
		}
	}
}


