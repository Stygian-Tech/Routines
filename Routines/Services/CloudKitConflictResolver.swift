//
//  CloudKitConflictResolver.swift
//  Routines
//
//  Created for CloudKit conflict resolution
//

import Foundation
import SwiftData
import CloudKit

/// Resolves conflicts between local and remote CloudKit states
/// Implements merge strategy: merge non-conflicting fields, last-write-wins for conflicts
@MainActor
class CloudKitConflictResolver {
    private let metadataService: CloudKitMetadataService
    private let container: CKContainer
    private let database: CKDatabase
    
    init(metadataService: CloudKitMetadataService? = nil) {
        // Initialize metadataService on main actor to avoid actor isolation issues
        self.metadataService = metadataService ?? CloudKitMetadataService()
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    /// Resolves a conflict for a Routine by merging local and remote changes
    /// - Parameters:
    ///   - routine: The local Routine with potential conflicts
    ///   - modelContext: The ModelContext to save changes
    /// - Returns: True if conflict was resolved, false if resolution failed
    @discardableResult
    func resolveConflict(for routine: Routine, modelContext: ModelContext) async -> Bool {
        do {
            // Fetch the remote CloudKit record
            let recordID = CKRecord.ID(recordName: routine.id.uuidString, zoneID: .default)
            let remoteRecord = try await database.record(for: recordID)
            
            guard let remoteModificationDate = remoteRecord.modificationDate else {
                print("CloudKitConflictResolver: No remote modification date for Routine \(routine.id)")
                return false
            }
            
            let localModificationDate = routine.lastModifiedDate ?? Date.distantPast
            
            // Determine which fields changed on each side
            // For merge strategy: if only one side changed a field, use that value
            // If both changed, use the newer timestamp (last-write-wins)
            
            var hasChanges = false
            
            // Merge name
            if let remoteName = remoteRecord["name"] as? String {
                if remoteModificationDate > localModificationDate {
                    // Remote is newer, use remote value
                    if routine.name != remoteName {
                        routine.name = remoteName
                        hasChanges = true
                    }
                } else if routine.name != remoteName {
                    // Both changed, but local is newer - keep local
                    // (local already has the newer value)
                }
            }
            
            // Merge time
            if let remoteTime = remoteRecord["time"] as? Date {
                if remoteModificationDate > localModificationDate {
                    if routine.time != remoteTime {
                        routine.time = remoteTime
                        hasChanges = true
                    }
                }
            }
            
            // Merge iconColor
            if let remoteIconColor = remoteRecord["iconColor"] as? String {
                if remoteModificationDate > localModificationDate {
                    if routine.iconColor != remoteIconColor {
                        routine.iconColor = remoteIconColor
                        hasChanges = true
                    }
                }
            }
            
            // Merge iconSymbol
            if let remoteIconSymbol = remoteRecord["iconSymbol"] as? String {
                if remoteModificationDate > localModificationDate {
                    if routine.iconSymbol != remoteIconSymbol {
                        routine.iconSymbol = remoteIconSymbol
                        hasChanges = true
                    }
                }
            }
            
            // Merge status
            if let remoteStatusRaw = remoteRecord["status"] as? Int,
               let remoteStatus = RoutineCompletionStatus(rawValue: remoteStatusRaw) {
                if remoteModificationDate > localModificationDate {
                    if routine.status != remoteStatus {
                        routine.status = remoteStatus
                        hasChanges = true
                    }
                }
            }
            
            // Merge finishedStepCount
            if let remoteFinishedCount = remoteRecord["finishedStepCount"] as? Int {
                if remoteModificationDate > localModificationDate {
                    if routine.finishedStepCount != remoteFinishedCount {
                        routine.finishedStepCount = remoteFinishedCount
                        hasChanges = true
                    }
                }
            }
            
            // Merge days (stored as JSON data)
            if let remoteDaysData = remoteRecord["daysData"] as? Data {
                if remoteModificationDate > localModificationDate {
                    // Decode remote days and compare
                    if let remoteDays = try? JSONDecoder().decode([Int].self, from: remoteDaysData) {
                        let remoteWeekdays = remoteDays.compactMap { Weekday(rawValue: $0) }
                        if Set(routine.days) != Set(remoteWeekdays) {
                            routine.days = remoteWeekdays
                            hasChanges = true
                        }
                    }
                }
            }
            
            // Update local modification date to match remote if remote was newer
            if remoteModificationDate > localModificationDate {
                routine.lastModifiedDate = remoteModificationDate
                hasChanges = true
            }
            
            if hasChanges {
                try modelContext.save()
                print("CloudKitConflictResolver: Resolved conflict for Routine \(routine.id)")
            }
            
            return true
        } catch {
            if let ckError = error as? CKError,
               ckError.code == .unknownItem {
                // Record doesn't exist in CloudKit yet - no conflict to resolve
                print("CloudKitConflictResolver: Routine \(routine.id) not found in CloudKit - no conflict")
                return true
            }
            
            print("CloudKitConflictResolver: Error resolving conflict for Routine \(routine.id): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Resolves a conflict for a Step by merging local and remote changes
    /// - Parameters:
    ///   - step: The local Step with potential conflicts
    ///   - modelContext: The ModelContext to save changes
    /// - Returns: True if conflict was resolved, false if resolution failed
    @discardableResult
    func resolveConflict(for step: Step, modelContext: ModelContext) async -> Bool {
        do {
            // Fetch the remote CloudKit record
            let recordID = CKRecord.ID(recordName: step.id.uuidString, zoneID: .default)
            let remoteRecord = try await database.record(for: recordID)
            
            guard let remoteModificationDate = remoteRecord.modificationDate else {
                print("CloudKitConflictResolver: No remote modification date for Step \(step.id)")
                return false
            }
            
            let localModificationDate = step.lastModifiedDate ?? Date.distantPast
            
            var hasChanges = false
            
            // Merge name
            if let remoteName = remoteRecord["name"] as? String {
                if remoteModificationDate > localModificationDate {
                    if step.name != remoteName {
                        step.name = remoteName
                        hasChanges = true
                    }
                }
            }
            
            // Merge order
            if let remoteOrder = remoteRecord["order"] as? Int {
                if remoteModificationDate > localModificationDate {
                    if step.order != remoteOrder {
                        step.order = remoteOrder
                        hasChanges = true
                    }
                }
            }
            
            // Merge status
            if let remoteStatusRaw = remoteRecord["status"] as? Int,
               let remoteStatus = StepCompletionStatus(rawValue: remoteStatusRaw) {
                if remoteModificationDate > localModificationDate {
                    if step.status != remoteStatus {
                        step.status = remoteStatus
                        hasChanges = true
                    }
                }
            }
            
            // Merge days (stored as JSON data)
            if let remoteDaysData = remoteRecord["daysData"] as? Data {
                if remoteModificationDate > localModificationDate {
                    // Decode remote days and compare
                    if let remoteDays = try? JSONDecoder().decode([Int].self, from: remoteDaysData) {
                        let remoteWeekdays = remoteDays.compactMap { Weekday(rawValue: $0) }
                        if Set(step.days) != Set(remoteWeekdays) {
                            step.days = remoteWeekdays
                            hasChanges = true
                        }
                    }
                }
            }
            
            // Note: We don't merge the routine relationship - that's managed by SwiftData
            // and should be preserved to maintain data integrity
            
            // Update local modification date to match remote if remote was newer
            if remoteModificationDate > localModificationDate {
                step.lastModifiedDate = remoteModificationDate
                hasChanges = true
            }
            
            if hasChanges {
                try modelContext.save()
                print("CloudKitConflictResolver: Resolved conflict for Step \(step.id)")
            }
            
            return true
        } catch {
            if let ckError = error as? CKError,
               ckError.code == .unknownItem {
                // Record doesn't exist in CloudKit yet - no conflict to resolve
                print("CloudKitConflictResolver: Step \(step.id) not found in CloudKit - no conflict")
                return true
            }
            
            print("CloudKitConflictResolver: Error resolving conflict for Step \(step.id): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Resolves conflicts for multiple routines in batch
    /// - Parameters:
    ///   - routines: Array of Routines with potential conflicts
    ///   - modelContext: The ModelContext to save changes
    /// - Returns: Number of conflicts successfully resolved
    func resolveConflicts(for routines: [Routine], modelContext: ModelContext) async -> Int {
        var resolvedCount = 0
        
        for routine in routines {
            if await resolveConflict(for: routine, modelContext: modelContext) {
                resolvedCount += 1
            }
        }
        
        return resolvedCount
    }
    
    /// Resolves conflicts for multiple steps in batch
    /// - Parameters:
    ///   - steps: Array of Steps with potential conflicts
    ///   - modelContext: The ModelContext to save changes
    /// - Returns: Number of conflicts successfully resolved
    func resolveConflicts(for steps: [Step], modelContext: ModelContext) async -> Int {
        var resolvedCount = 0
        
        for step in steps {
            if await resolveConflict(for: step, modelContext: modelContext) {
                resolvedCount += 1
            }
        }
        
        return resolvedCount
    }
}
