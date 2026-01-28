//
//  CloudKitMetadataService.swift
//  Routines
//
//  Created for CloudKit source of truth tracking
//

import Foundation
import CloudKit
import SwiftData

/// Service for accessing CloudKit record metadata to compare with local timestamps
/// Provides efficient access to CloudKit record modification dates
@MainActor
class CloudKitMetadataService {
    private let container: CKContainer
    private let database: CKDatabase
    private var metadataCache: [UUID: Date] = [:]
    private let cacheExpirationInterval: TimeInterval = 60.0 // Cache for 60 seconds
    private var cacheTimestamps: [UUID: Date] = [:]
    
    init() {
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    /// Fetches the modification date for a CloudKit record corresponding to a SwiftData model
    /// - Parameters:
    ///   - modelID: The UUID of the SwiftData model (Routine or Step)
    ///   - recordType: The CloudKit record type ("Routine" or "Step")
    /// - Returns: The modification date from CloudKit, or nil if not found or error
    func fetchModificationDate(for modelID: UUID, recordType: String) async -> Date? {
        // Check cache first
        if let cachedDate = metadataCache[modelID],
           let cacheTime = cacheTimestamps[modelID],
           Date().timeIntervalSince(cacheTime) < cacheExpirationInterval {
            return cachedDate
        }
        
        do {
            // Construct the CloudKit record ID from the SwiftData model ID
            // SwiftData uses a specific format for CloudKit record IDs
            let recordID = CKRecord.ID(recordName: modelID.uuidString, zoneID: .default)
            
            // Fetch the record from CloudKit
            let record = try await database.record(for: recordID)
            
            // Get the modification date
            guard let modificationDate = record.modificationDate else {
                print("CloudKitMetadataService: No modification date found for \(recordType) \(modelID)")
                return nil
            }
            
            // Cache the result
            metadataCache[modelID] = modificationDate
            cacheTimestamps[modelID] = Date()
            
            return modificationDate
        } catch {
            // Record might not exist in CloudKit yet (newly created locally)
            if let ckError = error as? CKError,
               ckError.code == .unknownItem {
                print("CloudKitMetadataService: Record not found in CloudKit for \(recordType) \(modelID) - likely not synced yet")
                return nil
            }
            
            print("CloudKitMetadataService: Error fetching modification date for \(recordType) \(modelID): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Compares local modification date with CloudKit modification date
    /// - Parameters:
    ///   - localDate: The local lastModifiedDate from the SwiftData model
    ///   - modelID: The UUID of the SwiftData model
    ///   - recordType: The CloudKit record type ("Routine" or "Step")
    /// - Returns: Comparison result indicating which is newer
    func compareModificationDates(
        localDate: Date?,
        modelID: UUID,
        recordType: String
    ) async -> ModificationDateComparison {
        // Fetch remote modification date
        guard let remoteDate = await fetchModificationDate(for: modelID, recordType: recordType) else {
            // If no remote date, local is the source (or unknown if local is also nil)
            if localDate == nil {
                return .unknown
            }
            return .localNewer // Local exists, remote doesn't
        }
        
        // If no local date, remote is newer
        guard let localDate = localDate else {
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
    
    /// Batch fetches modification dates for multiple models
    /// More efficient than individual fetches
    /// - Parameters:
    ///   - modelIDs: Array of UUIDs to fetch
    ///   - recordType: The CloudKit record type ("Routine" or "Step")
    /// - Returns: Dictionary mapping model IDs to their modification dates
    func batchFetchModificationDates(
        for modelIDs: [UUID],
        recordType: String
    ) async -> [UUID: Date] {
        var results: [UUID: Date] = [:]
        
        // Filter out cached items
        let uncachedIDs = modelIDs.filter { modelID in
            if let cachedDate = metadataCache[modelID],
               let cacheTime = cacheTimestamps[modelID],
               Date().timeIntervalSince(cacheTime) < cacheExpirationInterval {
                results[modelID] = cachedDate
                return false
            }
            return true
        }
        
        guard !uncachedIDs.isEmpty else {
            return results
        }
        
        // Create record IDs
        let recordIDs = uncachedIDs.map { CKRecord.ID(recordName: $0.uuidString, zoneID: .default) }
        
        do {
            // Batch fetch records
            let records = try await database.records(for: recordIDs)
            
            for (recordID, result) in records {
                switch result {
                case .success(let record):
                    if let modificationDate = record.modificationDate,
                       let modelID = UUID(uuidString: recordID.recordName) {
                        results[modelID] = modificationDate
                        metadataCache[modelID] = modificationDate
                        cacheTimestamps[modelID] = Date()
                    }
                case .failure(let error):
                    // Silently skip records that don't exist or have errors
                    if let ckError = error as? CKError,
                       ckError.code != .unknownItem {
                        print("CloudKitMetadataService: Error fetching record \(recordID.recordName): \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("CloudKitMetadataService: Error batch fetching modification dates: \(error.localizedDescription)")
        }
        
        return results
    }
    
    /// Clears the metadata cache
    func clearCache() {
        metadataCache.removeAll()
        cacheTimestamps.removeAll()
    }
    
    /// Clears cache for a specific model ID
    func clearCache(for modelID: UUID) {
        metadataCache.removeValue(forKey: modelID)
        cacheTimestamps.removeValue(forKey: modelID)
    }
}

/// Result of comparing local and remote modification dates
enum ModificationDateComparison {
    case localNewer    // Local modification is newer
    case remoteNewer   // Remote modification is newer
    case equal         // Both are effectively the same (within tolerance)
    case unknown       // Cannot determine (both missing or error)
}
