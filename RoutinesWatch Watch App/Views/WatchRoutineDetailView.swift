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
    @State private var showingEditRoutine = false
    @State private var showingEditStep = false
    @State private var stepToEdit: Step?
    
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
                    
                    if routine.status != .incomplete {
                        HStack(spacing: 4) {
                            CompletionIconView(for: routine)
                            Text(routine.status == .complete ? "Complete" : "Complete (skipped steps)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
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
                            },
                            onEdit: {
                                stepToEdit = step
                                showingEditStep = true
                            },
                            onDelete: {
                                deleteStep(step)
                            }
                        )
                    }
                }
                
                // Action buttons
                if !(routine.steps?.isEmpty ?? true) {
                    Divider()
                        .padding(.top, 4)
                    
                    VStack(spacing: 8) {
                        WatchActionButton(
                            title: "Add Step",
                            systemImage: "plus",
                            action: {
                                showingAddStep = true
                            },
                            tint: routine.getIconColor()
                        )
                        
                        WatchActionButton(
                            title: "Edit Routine",
                            systemImage: "pencil",
                            action: {
                                showingEditRoutine = true
                            },
                            tint: .none
                        )
                        
                        WatchResetButton(
                            action: {
                                Task {
                                    await resetRoutine(routine, using: routineManager)
                                }
                            }
                        )
                    }
                } else {
                    WatchActionButton(
                        title: "Add First Step",
                        systemImage: "plus",
                        action: {
                            showingAddStep = true
                        },
                        tint: routine.getIconColor(),
                    )
                }
            }
            .padding()
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddStep) {
            WatchAddStepView(routine: routine, isPresented: $showingAddStep)
        }
        .sheet(isPresented: $showingEditRoutine) {
            WatchEditRoutineView(
                isPresented: $showingEditRoutine,
                routine: routine
            )
        }
        .sheet(isPresented: $showingEditStep) {
            if let step = stepToEdit {
                WatchEditStepView(
                    step: step,
                    routine: routine,
                    isPresented: $showingEditStep
                )
            }
        }
        .onAppear {
            Task {
                do {
                    try await routineManager.checkRoutineCompletion(routine)
                } catch {
                    print("Error checking routine completion: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func cycleStepStatus(_ step: Step) {
        Task {
            do {
                try await stepManager.cycleStepStatus(step)
                try await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error cycling step status: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteStep(_ step: Step) {
        Task {
            do {
                // Get synchronizer to handle routine day updates
                let daySynchronizer = RoutineDaySynchronizer(modelContext: modelContext)
                
                // Delete the step
                try await stepManager.deleteSteps([step], from: routine)
                
                // Synchronize routine days after step deletion
                daySynchronizer.synchronizeRoutineDays(routine)
                try daySynchronizer.save()
                
                try await routineManager.checkRoutineCompletion(routine)
            } catch {
                print("Error deleting step: \(error.localizedDescription)")
            }
        }
    }
}

