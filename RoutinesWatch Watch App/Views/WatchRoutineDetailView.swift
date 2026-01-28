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
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    @Bindable var routine: Routine
    @State private var showingAddStep = false
    @State private var showingEditRoutine = false
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var stepManager: StepManager {
        StepManager(modelContext: modelContext, syncObserver: syncObserver)
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
    
}

