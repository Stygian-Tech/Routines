//
//  WatchRoutineDetailView.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData

struct WatchRoutineDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var routine: Routine
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: routine.iconSymbol)
                        .font(.title2)
                        .foregroundStyle(routine.getIconColor())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(routine.name)
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(routine.timeToString())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if routine.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding(.bottom, 4)
                
                Divider()
                
                // Steps list
                if routine.steps.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("No Steps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(routine.steps) { step in
                        Button(action: {
                            step.isComplete.toggle()
                            routine.checkRoutineCompletion()
                        }) {
                            HStack {
                                Image(systemName: step.isComplete ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(step.isComplete ? routine.getIconColor() : .secondary)
                                
                                Text(step.name)
                                    .foregroundStyle(.primary)
                                    .strikethrough(step.isComplete)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Reset button
                if !routine.steps.isEmpty {
                    Divider()
                        .padding(.top, 4)
                    
                    Button(action: {
                        routine.resetSteps()
                    }) {
                        HStack {
                            Image(systemName: "arrow.circlepath")
                            Text("Reset Steps")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(routine.getIconColor())
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
