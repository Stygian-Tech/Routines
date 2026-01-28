//
//  CloudKitNotificationManager.swift
//  Routines
//
//  Created by Sam Clemente on 1/27/25.
//

import Foundation
import CloudKit
import Combine
#if os(iOS)
import UIKit
#endif

/// Manages CloudKit push notification processing and sync triggering
/// This class handles the business logic for CloudKit notifications, making it SwiftUI-friendly
@MainActor
class CloudKitNotificationManager: ObservableObject {
    /// The last CloudKit notification ID that was processed
    @Published var lastNotificationID: String?
    
    /// Whether a sync is currently in progress
    @Published var isSyncing: Bool = false
    
    /// Publisher for notification events that SwiftUI views can observe
    let notificationReceived = PassthroughSubject<String, Never>()
    
    /// Publisher for sync completion events
    let syncCompleted = PassthroughSubject<Bool, Never>()
    
    private let syncObserver: CloudKitSyncObserver
    
    init(syncObserver: CloudKitSyncObserver) {
        self.syncObserver = syncObserver
    }
    
    /// Handles a remote notification from CloudKit
    /// - Parameter userInfo: The notification user info dictionary
    /// - Returns: The background fetch result indicating what happened (iOS only)
    #if os(iOS)
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        // Check if this is a CloudKit notification
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            // Not a CloudKit notification
            print("CloudKitNotificationManager: Received non-CloudKit notification")
            return .noData
        }
        
        let notificationID = notification.notificationID?.description ?? "unknown"
        print("CloudKitNotificationManager: Received CloudKit notification: \(notificationID)")
        
        // Update published properties
        lastNotificationID = notificationID
        notificationReceived.send(notificationID)
        
        // Trigger sync
        isSyncing = true
        await syncObserver.fetchChanges()
        isSyncing = false
        
        // Notify observers that sync completed
        syncCompleted.send(true)
        
        return .newData
    }
    #elseif os(watchOS)
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) async {
        // Check if this is a CloudKit notification
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            // Not a CloudKit notification
            print("CloudKitNotificationManager: Received non-CloudKit notification")
            return
        }
        
        let notificationID = notification.notificationID?.description ?? "unknown"
        print("CloudKitNotificationManager: Received CloudKit notification: \(notificationID)")
        
        // Update published properties
        lastNotificationID = notificationID
        notificationReceived.send(notificationID)
        
        // Trigger sync
        isSyncing = true
        await syncObserver.fetchChanges()
        isSyncing = false
        
        // Notify observers that sync completed
        syncCompleted.send(true)
    }
    #endif
}

