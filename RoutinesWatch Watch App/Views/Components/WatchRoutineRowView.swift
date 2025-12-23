//
//  WatchRoutineRowView.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI

struct WatchRoutineRowView: View {
    let routine: Routine
    let onDelete: ((Routine) -> Void)
    @State private var showingDeleteConfirm: Bool = false
    
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
                    if routine.steps == nil {
                        CompletionIconView(for: routine)
                            .foregroundStyle(.clear)
                    } else if routine.status == .complete || routine.status == .completeWithSkippedSteps {
                        CompletionIconView(for: routine)
                    } else {
                        RingProgressView(for: routine)
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                showingDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete \u{201C}\(routine.name)\u{201D}?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                onDelete(routine)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

