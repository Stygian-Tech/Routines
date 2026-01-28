//
//  CloudKitSyncObserver.swift
//  Routines
//
//  Created by Sam Clemente on 1/27/25.
//

import Foundation
import SwiftData
import Combine
import CoreData
import CloudKit
#if os(iOS)
import UIKit
#endif

extension Notification.Name {
    static let cloudKitSyncCompleted = Notification.Name("cloudKitSyncCompleted")
}

/// Observes CloudKit remote changes and processes them to keep the local store in sync
/// Provides periodic sync polling, app lifecycle hooks, and improved error handling
@MainActor
class CloudKitSyncObserver: ObservableObject {
    private let container: ModelContainer
    private var cancellables = Set<AnyCancellable>()
    nonisolated(unsafe) private var notificationObserver: NSObjectProtocol?
    
    // Published properties for sync status
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var lastSyncError: Error?
    @Published var remoteChangesNewerThanLocal: Set<UUID> = []
    
    // Source of truth services
    private let sourceOfTruthService: CloudKitSourceOfTruth
    private let conflictResolver: CloudKitConflictResolver
    
    // Periodic sync management
    private var syncTimer: Timer?
    private var isAppActive: Bool = true
    private let syncInterval: TimeInterval = 5.0 // Sync every 5 seconds when active (reduced frequency)
    
    // Retry management
    private var retryCount: Int = 0
    private let maxRetries: Int = 3
    private let baseRetryDelay: TimeInterval = 1.0
    
    init(container: ModelContainer) {
        self.container = container
        self.sourceOfTruthService = CloudKitSourceOfTruth()
        self.conflictResolver = CloudKitConflictResolver()
        setupRemoteChangeObserver()
        startPeriodicSync()
        setupAppLifecycleObservers()
    }
    
    nonisolated deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Sets up observation for NSPersistentStoreRemoteChange notifications
    private func setupRemoteChangeObserver() {
        let container = self.container
        // Listen for remote CloudKit changes using Combine
        NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                Task { @MainActor [weak self] in
                    await self?.fetchChanges(container: container)
                }
            }
            .store(in: &cancellables)
        
        // Also set up a direct observer as a backup
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor [weak self] in
                await self?.fetchChanges(container: container)
            }
        }
        
        #if os(iOS)
        print("CloudKitSyncObserver: Remote change observer set up")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: Remote change observer set up (WatchOS)")
        #endif
    }
    
    /// Sets up app lifecycle observers for automatic sync triggers
    private func setupAppLifecycleObservers() {
        #if os(iOS)
        // Observe app will enter foreground (iOS only)
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.handleAppWillEnterForeground()
                }
            }
            .store(in: &cancellables)
        
        // Observe app did become active (iOS only)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.handleAppDidBecomeActive()
                }
            }
            .store(in: &cancellables)
        
        // Observe app will resign active (iOS only)
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.handleAppWillResignActive()
                }
            }
            .store(in: &cancellables)
        #elseif os(watchOS)
        // WatchOS lifecycle is handled via scenePhase in the app files
        // This observer setup is intentionally minimal for watchOS
        #endif
    }
    
    /// Starts periodic sync when app is active
    func startPeriodicSync(interval: TimeInterval? = nil) {
        stopPeriodicSync()
        
        let syncInterval = interval ?? self.syncInterval
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isAppActive else { return }
                await self.fetchChanges()
            }
        }
        
        #if os(iOS)
        print("CloudKitSyncObserver: Started periodic sync (interval: \(syncInterval)s)")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: Started periodic sync (interval: \(syncInterval)s) (WatchOS)")
        #endif
    }
    
    /// Stops periodic sync
    func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    /// Handles app will enter foreground - triggers immediate sync
    func handleAppWillEnterForeground() {
        isAppActive = true
        startPeriodicSync()
        
        #if os(iOS)
        print("CloudKitSyncObserver: App will enter foreground, triggering sync")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: App will enter foreground, triggering sync (WatchOS)")
        #endif
        
        Task {
            await fetchChanges()
        }
    }
    
    /// Handles app did become active - triggers immediate sync
    func handleAppDidBecomeActive() {
        isAppActive = true
        startPeriodicSync()
        
        #if os(iOS)
        print("CloudKitSyncObserver: App did become active, triggering sync")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: App did become active, triggering sync (WatchOS)")
        #endif
        
        Task {
            await fetchChanges()
        }
    }
    
    /// Handles app will resign active - stops periodic sync
    func handleAppWillResignActive() {
        isAppActive = false
        stopPeriodicSync()
        
        #if os(iOS)
        print("CloudKitSyncObserver: App will resign active, stopping periodic sync")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: App will resign active, stopping periodic sync (WatchOS)")
        #endif
    }
    
    /// Explicitly fetches changes from CloudKit and processes them
    func fetchChanges() async {
        await fetchChanges(container: container)
    }
    
    /// Internal method to fetch changes from CloudKit with retry logic
    private func fetchChanges(container: ModelContainer) async {
        // Prevent duplicate syncs
        guard !isSyncing else {
            return // Silently skip if already syncing
        }
        
        isSyncing = true
        lastSyncError = nil
        
        // Use the container's main context to ensure changes propagate to views
        let context = ModelContext(container)
        
        do {
            // First, save any pending local changes to push them to CloudKit
            if context.hasChanges {
                try context.save()
                // Give CloudKit a moment to process the save
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            }
            
            // Process pending changes to incorporate any remote updates
            context.processPendingChanges()
            
            // Force a fetch which triggers SwiftData to check CloudKit for updates
            // This is critical - fetching forces the persistent store to sync with CloudKit
            // SwiftData with CloudKit will automatically fetch remote changes when we fetch
            let routineDescriptor = FetchDescriptor<Routine>(
                sortBy: [SortDescriptor(\Routine.time, order: .forward)]
            )
            let routines = try context.fetch(routineDescriptor)
            
            // Also fetch steps to ensure all related data is synced
            let stepDescriptor = FetchDescriptor<Step>()
            let steps = try context.fetch(stepDescriptor)
            
            // Ensure timestamps are initialized for existing data (backward compatibility)
            for routine in routines {
                routine.ensureTimestampInitialized()
            }
            for step in steps {
                step.ensureTimestampInitialized()
            }
            
            // Process pending changes again after fetching to incorporate any new remote changes
            // This applies any remote changes that were fetched from CloudKit
            context.processPendingChanges()
            
            // Check source of truth for all routines and steps
            await checkSourceOfTruth(routines: routines, steps: steps, context: context)
            
            // Note: @Query views will automatically update when the persistent store changes
            // SwiftData handles this automatically when CloudKit syncs changes
            
            // Success - reset retry count
            retryCount = 0
            lastSyncDate = Date()
            isSyncing = false
            
            // Only log when count changes or every 30 seconds to reduce spam
            let lastCount = UserDefaults.standard.integer(forKey: "lastRoutineCount")
            let timeSinceLastLog = lastSyncDate.map { Date().timeIntervalSince($0) } ?? 999
            let shouldLog = lastCount != routines.count || timeSinceLastLog > 30
            
            if shouldLog {
                UserDefaults.standard.set(routines.count, forKey: "lastRoutineCount")
                #if os(iOS)
                print("CloudKitSyncObserver: Synced (found \(routines.count) routines, \(steps.count) steps)")
                #elseif os(watchOS)
                print("CloudKitSyncObserver: Synced (found \(routines.count) routines, \(steps.count) steps) (WatchOS)")
                #endif
            }
            
            // Post a notification that sync completed so views can refresh if needed
            NotificationCenter.default.post(name: .cloudKitSyncCompleted, object: nil)
            
        } catch {
            isSyncing = false
            lastSyncError = error
            
            #if os(iOS)
            print("CloudKitSyncObserver: Error fetching changes: \(error.localizedDescription)")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Error fetching changes: \(error.localizedDescription) (WatchOS)")
            #endif
            
            // Retry with exponential backoff
            if retryCount < maxRetries {
                retryCount += 1
                let delay = baseRetryDelay * pow(2.0, Double(retryCount - 1))
                
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await fetchChanges(container: container)
            } else {
                retryCount = 0 // Reset for next sync attempt
            }
        }
    }
    
    /// Checks source of truth for routines and steps, tracking which have remote changes newer than local
    /// - Parameters:
    ///   - routines: Array of Routines to check
    ///   - steps: Array of Steps to check
    ///   - context: The ModelContext for saving changes
    private func checkSourceOfTruth(routines: [Routine], steps: [Step], context: ModelContext) async {
        var remoteNewerIDs = Set<UUID>()
        var conflictsToResolve: [Routine] = []
        var stepConflictsToResolve: [Step] = []
        
        // Batch check source of truth for routines
        let routineSourceOfTruth = await sourceOfTruthService.batchDetermineSourceOfTruth(for: routines)
        
        for (routineID, sourceOfTruth) in routineSourceOfTruth {
            switch sourceOfTruth {
            case .remote:
                remoteNewerIDs.insert(routineID)
                if let routine = routines.first(where: { $0.id == routineID }) {
                    conflictsToResolve.append(routine)
                }
                #if os(iOS)
                print("CloudKitSyncObserver: Routine \(routineID) has remote changes newer than local")
                #elseif os(watchOS)
                print("CloudKitSyncObserver: Routine \(routineID) has remote changes newer than local (WatchOS)")
                #endif
            case .conflict:
                if let routine = routines.first(where: { $0.id == routineID }) {
                    conflictsToResolve.append(routine)
                }
                #if os(iOS)
                print("CloudKitSyncObserver: Routine \(routineID) has conflict (both local and remote modified)")
                #elseif os(watchOS)
                print("CloudKitSyncObserver: Routine \(routineID) has conflict (both local and remote modified) (WatchOS)")
                #endif
            case .local, .unknown:
                // Local is source of truth or unknown - no action needed
                break
            }
        }
        
        // Batch check source of truth for steps
        let stepSourceOfTruth = await sourceOfTruthService.batchDetermineSourceOfTruth(for: steps)
        
        for (stepID, sourceOfTruth) in stepSourceOfTruth {
            switch sourceOfTruth {
            case .remote:
                remoteNewerIDs.insert(stepID)
                if let step = steps.first(where: { $0.id == stepID }) {
                    stepConflictsToResolve.append(step)
                }
                #if os(iOS)
                print("CloudKitSyncObserver: Step \(stepID) has remote changes newer than local")
                #elseif os(watchOS)
                print("CloudKitSyncObserver: Step \(stepID) has remote changes newer than local (WatchOS)")
                #endif
            case .conflict:
                if let step = steps.first(where: { $0.id == stepID }) {
                    stepConflictsToResolve.append(step)
                }
                #if os(iOS)
                print("CloudKitSyncObserver: Step \(stepID) has conflict (both local and remote modified)")
                #elseif os(watchOS)
                print("CloudKitSyncObserver: Step \(stepID) has conflict (both local and remote modified) (WatchOS)")
                #endif
            case .local, .unknown:
                // Local is source of truth or unknown - no action needed
                break
            }
        }
        
        // Update published property
        remoteChangesNewerThanLocal = remoteNewerIDs
        
        // Resolve conflicts if any
        if !conflictsToResolve.isEmpty {
            #if os(iOS)
            print("CloudKitSyncObserver: Resolving \(conflictsToResolve.count) routine conflicts")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Resolving \(conflictsToResolve.count) routine conflicts (WatchOS)")
            #endif
            let resolvedCount = await conflictResolver.resolveConflicts(for: conflictsToResolve, modelContext: context)
            #if os(iOS)
            print("CloudKitSyncObserver: Resolved \(resolvedCount) routine conflicts")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Resolved \(resolvedCount) routine conflicts (WatchOS)")
            #endif
        }
        
        if !stepConflictsToResolve.isEmpty {
            #if os(iOS)
            print("CloudKitSyncObserver: Resolving \(stepConflictsToResolve.count) step conflicts")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Resolving \(stepConflictsToResolve.count) step conflicts (WatchOS)")
            #endif
            let resolvedCount = await conflictResolver.resolveConflicts(for: stepConflictsToResolve, modelContext: context)
            #if os(iOS)
            print("CloudKitSyncObserver: Resolved \(resolvedCount) step conflicts")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Resolved \(resolvedCount) step conflicts (WatchOS)")
            #endif
        }
    }
}

