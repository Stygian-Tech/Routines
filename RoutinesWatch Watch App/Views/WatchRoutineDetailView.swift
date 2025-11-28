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
    @State private var showingStepActions = false
    @State private var selectedStep: Step?
    @State private var showingAddStep = false
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext)
    }
    
    var todaySteps: [Step] {
        (routine.steps ?? []).filter { $0.isToday() }.sorted { $0.order < $1.order }
    }
    
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
                    
                    if routine.status == .complete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if routine.status == .completeWithSkippedSteps {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding(.bottom, 4)
                
                Divider()
                
                // Steps list
                if todaySteps.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("No Steps Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(todaySteps) { step in
                        WatchStepRowView(
                            step: step,
                            routine: routine,
                            onTap: {
                                cycleStepStatus(step)
                            }
                        )
                    }
                }
                
                // Action buttons
                if !(routine.steps?.isEmpty ?? true) {
                    Divider()
                        .padding(.top, 4)
                    
                    VStack(spacing: 8) {
                        Button(action: {
                            showingAddStep = true
                        }) {
                            Label("Add Step", systemImage: "plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(routine.getIconColor())
                        
                        Button(action: {
                            Task {
                                do {
                                    try await routineManager.resetRoutine(routine)
                                    try await routineManager.save()
                                } catch {
                                    print("Error resetting routine: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Label("Reset", systemImage: "arrow.circlepath")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                    }
                } else {
                    Button(action: {
                        showingAddStep = true
                    }) {
                        Label("Add First Step", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(routine.getIconColor())
                }
            }
            .padding()
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddStep) {
            WatchAddStepView(routine: routine, isPresented: $showingAddStep)
        }
        .onAppear {
            Task {
                await routineManager.checkRoutineCompletion(routine)
            }
        }
    }
    
    private func cycleStepStatus(_ step: Step) {
        Task {
            do {
                try await stepManager.cycleStepStatus(step)
                await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error cycling step status: \(error.localizedDescription)")
            }
        }
    }
}
