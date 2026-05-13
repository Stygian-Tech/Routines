//
//  EditRoutineSheet.swift
//  Routines
//
//  Created to modularize sheets
//

import SwiftUI
import SwiftData

struct EditRoutineSheet: View {
    let routine: Routine
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var syncObserver: CloudKitSyncObserver
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext, syncObserver: syncObserver)
    }
    
    private var daySynchronizer: RoutineDaySynchronizer {
        RoutineDaySynchronizer(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            EditRoutineView(routine: routine) { tempRoutine in
                modelContext.delete(tempRoutine)
                isPresented = false
            } onSave: { tempRoutine in
                Task {
                    do {
                        // Find days that were removed from routine
                        let oldDays = Set(routine.days)
                        let newDays = Set(tempRoutine.days)
                        let removedDays = oldDays.subtracting(newDays)
                        let addedDays = newDays.subtracting(oldDays)
                        
                        // Cascade removed days to steps using synchronizer
                        if !removedDays.isEmpty {
                            for removedDay in removedDays {
                                _ = daySynchronizer.cascadeRemoveDayFromRoutine(removedDay, routine: routine)
                            }
                            // Explicitly save step changes
                            try modelContext.save()
                        }
                        
                        // Add any new days to routine (don't cascade to steps)
                        if !addedDays.isEmpty {
                            var routineDays = routine.days
                            for addedDay in addedDays {
                                if !routineDays.contains(addedDay) {
                                    routineDays.append(addedDay)
                                }
                            }
                            routine.days = routineDays.sorted()
                        }
                        
                        // Final synchronization: ensure routine days are superset of all step days
                        // This handles the case where steps added days that expanded routine
                        daySynchronizer.synchronizeRoutineDays(routine)
                        
                        // Use routine.days (which has been synchronized) instead of tempRoutine.days
                        // to ensure we include any days that steps added
                        try await routineManager.updateRoutine(
                            routine,
                            name: tempRoutine.name,
                            time: tempRoutine.time,
                            iconColor: tempRoutine.iconColor,
                            iconSymbol: tempRoutine.iconSymbol,
                            days: routine.days,
                            repeatInterval: tempRoutine.repeatInterval,
                            repeatAnchorDate: tempRoutine.repeatAnchorDate
                        )
                        modelContext.delete(tempRoutine)
                        isPresented = false
                    } catch {
                        print("Error updating routine: \(error.localizedDescription)")
                    }
                }
            }
            .navigationTitle("Edit \(routine.name)")
        }
    }
}

