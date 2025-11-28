//
//  WatchRoutineRowView.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI

struct WatchRoutineRowView: View {
    let routine: Routine
    
    var body: some View {
        HStack {
            Image(systemName: routine.iconSymbol)
                .foregroundStyle(routine.getIconColor())
                .frame(width: 20)
                .padding(.trailing, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if routine.status == .complete || routine.status == .completeWithSkippedSteps {
                        CompletionIconView(routine: routine)
                    } else if routine.steps != nil {
                        EmptyView()
                    } else {
                        RingProgressView(routine: routine)
                            .frame(width: 12, height: 12)
                            .padding(.trailing, 4)
                            .layoutPriority(0)
                    }
                    
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(routine.timeToString())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

