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
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let editAction = onEdit {
                Button(action: editAction) {
                    Label("Edit Step", systemImage: "pencil")
                }
            }
            if let deleteAction = onDelete {
                Button(role: .destructive, action: deleteAction) {
                    Label("Delete Step", systemImage: "trash")
                }
            }
        }
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

