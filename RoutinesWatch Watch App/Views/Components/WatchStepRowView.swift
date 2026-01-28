//
//  WatchStepRowView.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI

struct WatchStepRowView: View {
    let step: Step
    let routine: Routine
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: step.status.icon)
                    .foregroundStyle(stepColor)
                    .font(.title3)
                
                Text(step.name)
                    .foregroundStyle(.primary)
                    .font(.body)
                
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    private var stepColor: Color {
        switch step.status {
        case .incomplete:
            return .secondary
        case .complete:
            return routine.getIconColor()
        case .skipped:
            return .orange
        }
    }
}

