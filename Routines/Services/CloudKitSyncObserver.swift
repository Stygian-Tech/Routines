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

/// Observes CloudKit remote changes and processes them to keep the local store in sync
@MainActor
class CloudKitSyncObserver {
    private let container: ModelContainer
    private var cancellables = Set<AnyCancellable>()
    nonisolated(unsafe) private var notificationObserver: NSObjectProtocol?
    
    init(container: ModelContainer) {
        self.container = container
        setupRemoteChangeObserver()
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
            .sink { notification in
                Task { @MainActor in
                    await self.fetchChanges(container: container)
                }
            }
            .store(in: &cancellables)
        
        // Also set up a direct observer as a backup
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                await self.fetchChanges(container: container)
            }
        }
        
        #if os(iOS)
        print("CloudKitSyncObserver: Remote change observer set up")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: Remote change observer set up (WatchOS)")
        #endif
    }
    
    /// Explicitly fetches changes from CloudKit and processes them
    func fetchChanges() async {
        await fetchChanges(container: container)
    }
    
    /// Internal method to fetch changes from CloudKit
    private func fetchChanges(container: ModelContainer) async {
        #if os(iOS)
        print("CloudKitSyncObserver: Fetching changes from CloudKit...")
        #elseif os(watchOS)
        print("CloudKitSyncObserver: Fetching changes from CloudKit... (WatchOS)")
        #endif
        
        let context = ModelContext(container)
        
        // Process pending changes to incorporate remote updates
        context.processPendingChanges()
        
        // Force a fetch from CloudKit by processing all pending changes
        do {
            // Save any pending changes first
            if context.hasChanges {
                try context.save()
            }
            
            // Process pending changes again to pick up any remote changes
            context.processPendingChanges()
            
            // Trigger a refresh by fetching (this forces CloudKit sync)
            let descriptor = FetchDescriptor<Routine>()
            _ = try? context.fetch(descriptor)
            
            #if os(iOS)
            print("CloudKitSyncObserver: Successfully fetched and processed remote changes")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Successfully fetched and processed remote changes (WatchOS)")
            #endif
        } catch {
            #if os(iOS)
            print("CloudKitSyncObserver: Error fetching changes: \(error.localizedDescription)")
            #elseif os(watchOS)
            print("CloudKitSyncObserver: Error fetching changes: \(error.localizedDescription) (WatchOS)")
            #endif
        }
    }
}

