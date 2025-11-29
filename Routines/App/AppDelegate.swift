//
//  AppDelegate.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//

import Foundation
import UIKit

// MARK: - AppDelegate for handling CloudKit push notifications
/// Minimal AppDelegate that only handles required iOS delegate methods.
/// Business logic is handled by CloudKitNotificationManager.
class AppDelegate: NSObject, UIApplicationDelegate {
    var notificationManager: CloudKitNotificationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Register for remote notifications
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("AppDelegate: Successfully registered for remote notifications")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("AppDelegate: Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Route to CloudKitNotificationManager for processing
        guard let notificationManager = notificationManager else {
            print("AppDelegate: Warning - CloudKitNotificationManager not set, cannot process notification")
            completionHandler(.noData)
            return
        }
        
        Task { @MainActor in
            let result = await notificationManager.handleRemoteNotification(userInfo)
            completionHandler(result)
        }
    }
}

