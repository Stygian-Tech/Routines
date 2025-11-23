//
//  CloudKitSubscriptionManager.swift
//  Routines
//
//  Created by Sam Clemente on 1/27/25.
//

import Foundation
import CloudKit

/// Manages CloudKit subscriptions for push notifications
@MainActor
class CloudKitSubscriptionManager {
    private let container: CKContainer
    private let database: CKDatabase
    private let subscriptionID = "com.sam-clemente.routines-app.database-subscription"
    
    init() {
        // Get the default container (same one used by SwiftData)
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    /// Sets up CloudKit database subscription for push notifications
    func setupSubscription() async {
        do {
            // Check if subscription already exists
            let existingSubscription = try await database.subscription(for: subscriptionID)
            print("CloudKitSubscriptionManager: Subscription already exists")
            return
        } catch {
            // Subscription doesn't exist, create it
            print("CloudKitSubscriptionManager: Creating new subscription")
        }
        
        // Create a database subscription
        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
        
        // Configure notification info
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = false
        subscription.notificationInfo = notificationInfo
        
        do {
            // Save the subscription
            let savedSubscription = try await database.save(subscription)
            print("CloudKitSubscriptionManager: Successfully created subscription: \(savedSubscription.subscriptionID)")
        } catch {
            print("CloudKitSubscriptionManager: Error creating subscription: \(error.localizedDescription)")
            // Don't fail if subscription creation fails - app can still work with polling
        }
    }
    
    /// Removes the subscription (useful for testing or cleanup)
    func removeSubscription() async {
        do {
            try await database.deleteSubscription(withID: subscriptionID)
            print("CloudKitSubscriptionManager: Successfully removed subscription")
        } catch {
            print("CloudKitSubscriptionManager: Error removing subscription: \(error.localizedDescription)")
        }
    }
}

