//
//  CloudKitSourceOfTruth.swift
//  Routines
//
//  Created for CloudKit source of truth tracking
//

import Foundation
import SwiftData

/// Determines which state (local or remote) is the source of truth for CloudKit-synced models
@MainActor
class CloudKitSourceOfTruth {
    private let metadataService: CloudKitMetadataService
    
    init(metadataService: CloudKitMetadataService? = nil) {
        // Initialize metadataService on main actor to avoid actor isolation issues
        self.metadataService = metadataService ?? CloudKitMetadataService()
    }
    
    /// Determines the source of truth for a Routine
    /// - Parameter routine: The Routine to check
    /// - Returns: SourceOfTruth enum indicating which state is authoritative
    func determineSourceOfTruth(for routine: Routine) async -> SourceOfTruth {
        let comparison = await metadataService.compareModificationDates(
            localDate: routine.lastModifiedDate,
            modelID: routine.id,
            recordType: "Routine"
        )
        
        return mapComparisonToSourceOfTruth(comparison)
    }
    
    /// Determines the source of truth for a Step
    /// - Parameter step: The Step to check
    /// - Returns: SourceOfTruth enum indicating which state is authoritative
    func determineSourceOfTruth(for step: Step) async -> SourceOfTruth {
        let comparison = await metadataService.compareModificationDates(
            localDate: step.lastModifiedDate,
            modelID: step.id,
            recordType: "Step"
        )
        
        return mapComparisonToSourceOfTruth(comparison)
    }
    
    /// Efficiently checks if remote state is newer than local state
    /// - Parameter routine: The Routine to check
    /// - Returns: True if remote modification is newer than local
    func isRemoteNewer(than routine: Routine) async -> Bool {
        let sourceOfTruth = await determineSourceOfTruth(for: routine)
        return sourceOfTruth == .remote
    }
    
    /// Efficiently checks if remote state is newer than local state
    /// - Parameter step: The Step to check
    /// - Returns: True if remote modification is newer than local
    func isRemoteNewer(than step: Step) async -> Bool {
        let sourceOfTruth = await determineSourceOfTruth(for: step)
        return sourceOfTruth == .remote
    }
    
    /// Batch determines source of truth for multiple routines
    /// - Parameter routines: Array of Routines to check
    /// - Returns: Dictionary mapping routine IDs to their source of truth
    func batchDetermineSourceOfTruth(for routines: [Routine]) async -> [UUID: SourceOfTruth] {
        var results: [UUID: SourceOfTruth] = [:]
        
        // Batch fetch remote modification dates
        let routineIDs = routines.map { $0.id }
        let remoteDates = await metadataService.batchFetchModificationDates(
            for: routineIDs,
            recordType: "Routine"
        )
        
        // Compare each routine
        for routine in routines {
            let localDate = routine.lastModifiedDate
            let remoteDate = remoteDates[routine.id]
            
            let comparison = compareDates(local: localDate, remote: remoteDate)
            results[routine.id] = mapComparisonToSourceOfTruth(comparison)
        }
        
        return results
    }
    
    /// Batch determines source of truth for multiple steps
    /// - Parameter steps: Array of Steps to check
    /// - Returns: Dictionary mapping step IDs to their source of truth
    func batchDetermineSourceOfTruth(for steps: [Step]) async -> [UUID: SourceOfTruth] {
        var results: [UUID: SourceOfTruth] = [:]
        
        // Batch fetch remote modification dates
        let stepIDs = steps.map { $0.id }
        let remoteDates = await metadataService.batchFetchModificationDates(
            for: stepIDs,
            recordType: "Step"
        )
        
        // Compare each step
        for step in steps {
            let localDate = step.lastModifiedDate
            let remoteDate = remoteDates[step.id]
            
            let comparison = compareDates(local: localDate, remote: remoteDate)
            results[step.id] = mapComparisonToSourceOfTruth(comparison)
        }
        
        return results
    }
    
    /// Checks if there's a conflict (both local and remote have been modified)
    /// - Parameter routine: The Routine to check
    /// - Returns: True if both local and remote have modifications that differ
    func hasConflict(for routine: Routine) async -> Bool {
        let sourceOfTruth = await determineSourceOfTruth(for: routine)
        return sourceOfTruth == .conflict
    }
    
    /// Checks if there's a conflict (both local and remote have been modified)
    /// - Parameter step: The Step to check
    /// - Returns: True if both local and remote have modifications that differ
    func hasConflict(for step: Step) async -> Bool {
        let sourceOfTruth = await determineSourceOfTruth(for: step)
        return sourceOfTruth == .conflict
    }
    
    // MARK: - Private Helpers
    
    private func mapComparisonToSourceOfTruth(_ comparison: ModificationDateComparison) -> SourceOfTruth {
        switch comparison {
        case .localNewer:
            return .local
        case .remoteNewer:
            return .remote
        case .equal:
            return .local // If equal, prefer local (no sync needed)
        case .unknown:
            return .unknown
        }
    }
    
    private func compareDates(local: Date?, remote: Date?) -> ModificationDateComparison {
        // If no remote date, local is the source (or unknown if local is also nil)
        guard let remoteDate = remote else {
            if local == nil {
                return .unknown
            }
            return .localNewer
        }
        
        // If no local date, remote is newer
        guard let localDate = local else {
            return .remoteNewer
        }
        
        // Compare dates with small tolerance for clock skew (1 second)
        let timeDifference = remoteDate.timeIntervalSince(localDate)
        
        if abs(timeDifference) < 1.0 {
            return .equal
        } else if timeDifference > 0 {
            return .remoteNewer
        } else {
            return .localNewer
        }
    }
}

/// Represents which state is the source of truth for a CloudKit-synced model
enum SourceOfTruth {
    case local      // Local state is authoritative
    case remote     // Remote (CloudKit) state is authoritative
    case unknown    // Cannot determine (missing data or error)
    case conflict   // Both local and remote have been modified (requires resolution)
}
