//
//  WatchRoutineListView.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData

struct WatchRoutineListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Routine.time) var routines: [Routine]
    @State private var selectedRoutineID: UUID?
    @State private var showingAddRoutine = false
    
    var body: some View {
        NavigationStack {
            if routines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Routines")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                    
                    Button(action: {
                        showingAddRoutine = true
                    }) {
                        Label("Create Routine", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                .navigationTitle("Routines")
            } else {
                List {
                    ForEach(routines) { routine in
                        NavigationLink(value: routine.id) {
                            WatchRoutineRowView(routine: routine)
                        }
                    }
                }
                .navigationTitle("Routines")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showingAddRoutine = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add Routine")
                    }
                }
                .navigationDestination(for: UUID.self) { id in
                    if let routine = routines.first(where: { $0.id == id }) {
                        WatchRoutineDetailView(routine: routine)
                    } else {
                        Text("Routine Not Found")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddRoutine) {
            WatchAddRoutineView(isPresented: $showingAddRoutine)
        }
        .onAppear {
            // Check routine completion on appear
            for routine in routines {
                routine.checkRoutineCompletion()
            }
        }
    }
}

struct WatchRoutineRowView: View {
    let routine: Routine
    
    var body: some View {
        HStack {
            Image(systemName: routine.iconSymbol)
                .foregroundStyle(routine.getIconColor())
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(routine.timeToString())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if routine.status == .complete || routine.status == .completeWithSkippedSteps {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}
