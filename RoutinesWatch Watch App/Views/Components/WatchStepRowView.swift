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
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
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
                
                // Action buttons for watchOS (replaces deprecated contextMenu)
                // On watchOS, contextMenu and Menu are unavailable, so we show buttons directly
                HStack(spacing: 4) {
                    if let editAction = onEdit {
                        Button(action: editAction) {
                            Image(systemName: "pencil")
                                .foregroundStyle(.blue)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                    if let deleteAction = onDelete {
                        Button(action: deleteAction) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }
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

