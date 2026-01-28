//
//  RoutinesApp.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData
import UserNotifications
import TipKit
import CloudKit

@main
struct RoutinesApp: App {
    var resetTipsOnLaunch = true
    let container: ModelContainer
    private let cloudKitSyncObserver: CloudKitSyncObserver
    private let cloudKitSubscriptionManager: CloudKitSubscriptionManager
    private let cloudKitNotificationManager: CloudKitNotificationManager
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private var isUITestSeedEnabled: Bool { ProcessInfo.processInfo.arguments.contains("UI_TEST_SEED") }
    private static let migrationKey = "com.sam-clemente.routines-app.localToCloudKitMigrationCompleted"
    
    init() {
        do {
            // Configure schema with Routine and Step models
            let schema = Schema([Routine.self, Step.self])
            
            // Configure ModelConfiguration with CloudKit for sync
            // Using .automatic will use the iCloud container configured in Xcode
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Set up CloudKit sync observer for real-time updates
            cloudKitSyncObserver = CloudKitSyncObserver(container: container)
            
            // Set up CloudKit notification manager for handling push notifications
            cloudKitNotificationManager = CloudKitNotificationManager(syncObserver: cloudKitSyncObserver)
            
            // Set up CloudKit subscription manager for push notifications
            cloudKitSubscriptionManager = CloudKitSubscriptionManager()
            
            // Log CloudKit configuration for debugging
            print("iOS: ModelContainer initialized with CloudKit")
            print("iOS: Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
            
            // Set up CloudKit subscription for push notifications
            let subscriptionManager = cloudKitSubscriptionManager
            Task { @MainActor in
                await subscriptionManager.setupSubscription()
            }
            
            // Check initial data count and perform migration if needed
            Task { [container] in
                let context = ModelContext(container)
                do {
                    let routines: [Routine] = try context.fetch(FetchDescriptor<Routine>())
                    print("iOS: Routine count: \(routines.count)")
                    
                    // Perform lazy migration on app launch
                    for routine in routines {
                        routine.migrateDaysIfNeeded()
                        for step in routine.steps ?? [] {
                            step.migrateDaysIfNeeded()
                        }
                    }
                    try context.save()
                    
                    if routines.isEmpty {
                        print("iOS: WARNING - No routines found. Make sure data was migrated to CloudKit.")
                    }
                } catch {
                    print("iOS: Error fetching routines: \(error)")
                }
            }
        } catch {
            fatalError("Failed to load model container: \(error.localizedDescription)")
        }
        
        if isUITestSeedEnabled {
            seedDataForUITests()
        }
        configureTips()
    }
    
    var body: some Scene {
        WindowGroup {
            AppLifecycleSyncView(syncObserver: cloudKitSyncObserver) {
                RoutineListView()
                    .onAppear {
                        // Set up the notification manager reference in app delegate
                        appDelegate.notificationManager = cloudKitNotificationManager
                        promptForNotifications()
                        // Migrate local data to CloudKit if needed
                        Task { [container] in
                            await Self.migrateLocalDataToCloudKit(container: container)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
                        // Refresh UI when locale changes
                        // Views will automatically update via LocaleObserver
                    }
                    .environmentObject(cloudKitSyncObserver)
            }
        }
        .modelContainer(container)
    }

    private func promptForNotifications() {
        Task {
            let currentCenter = UNUserNotificationCenter.current()
            do {
                let _ = try await currentCenter.requestAuthorization(options: [.sound, .alert, .badge])
                print("Notifications Requested")
            } catch {
                print("Error handling notifications \(error.localizedDescription)")
            }
        }
    }
    
    private func seedDataForUITests() {
        let context = ModelContext(container)
        do {
            let existing: [Routine] = try context.fetch(FetchDescriptor<Routine>())
            if existing.isEmpty {
                let routine = Routine(name: "Morning", time: Date(), iconColor: SystemColors.purple.rawValue, iconSymbol: "sun.and.horizon")
                routine.days = DateUtility.allWeekdays()
                let step1 = Step(name: "Brush Teeth", routine: routine, order: 0, days: routine.days)
                let step2 = Step(name: "Coffee", routine: routine, order: 1, days: routine.days)
                context.insert(routine)
                context.insert(step1)
                context.insert(step2)
                routine.steps = [step1, step2]
                try context.save()
            }
        } catch {
            print("UITest seed failed: \(error)")
        }
    }

    private func configureTips() {
        Task {
            do {
                if resetTipsOnLaunch {
                    try Tips.resetDatastore()
                    print("Resetting Tips")
                }
                try Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
                print("Configured Tips")
            } catch {
                print("Error initializing TipKit: \(error.localizedDescription)")
            }
        }
    }
    
    /// Migrates local SwiftData store to CloudKit-enabled store
    /// This function checks if migration has already been completed, and if not,
    /// attempts to load data from a local-only store and copy it to CloudKit
    private static func migrateLocalDataToCloudKit(container: ModelContainer) async {
        // Check if migration has already been completed
        if UserDefaults.standard.bool(forKey: Self.migrationKey) {
            print("Migration already completed, skipping")
            return
        }
        
        // Check if CloudKit store already has data
        let cloudKitContext = ModelContext(container)
        do {
            let existingRoutines: [Routine] = try cloudKitContext.fetch(FetchDescriptor<Routine>())
            if !existingRoutines.isEmpty {
                print("CloudKit store already contains data, marking migration as complete")
                UserDefaults.standard.set(true, forKey: Self.migrationKey)
                return
            }
        } catch {
            print("Error checking CloudKit store: \(error.localizedDescription)")
        }
        
        // Try to load from local-only store
        do {
            let schema = Schema([Routine.self, Step.self])
            
            // Get the default local store URL (where data was stored before CloudKit)
            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let localStoreURL = appSupportURL.appendingPathComponent("default.store")
            
            // Check if local store file exists
            guard FileManager.default.fileExists(atPath: localStoreURL.path) else {
                print("Local store file not found at \(localStoreURL.path)")
                UserDefaults.standard.set(true, forKey: Self.migrationKey)
                return
            }
            
            // Create a local-only configuration pointing to the old store
            let localConfiguration = ModelConfiguration(
                schema: schema,
                url: localStoreURL,
                cloudKitDatabase: .none
            )
            
            let localContainer = try ModelContainer(for: schema, configurations: [localConfiguration])
            let localContext = ModelContext(localContainer)
            
            // Fetch all routines from local store
            let localRoutines: [Routine] = try localContext.fetch(FetchDescriptor<Routine>())
            
            if localRoutines.isEmpty {
                print("No local data found to migrate")
                UserDefaults.standard.set(true, forKey: Self.migrationKey)
                return
            }
            
            print("Found \(localRoutines.count) routines in local store, migrating to CloudKit...")
            
            // Copy routines and steps to CloudKit store
            for localRoutine in localRoutines {
                // Create a new routine in CloudKit store with same properties
                let newRoutine = Routine(
                    name: localRoutine.name,
                    time: localRoutine.time,
                    iconColor: localRoutine.iconColor,
                    iconSymbol: localRoutine.iconSymbol
                )
                newRoutine.status = localRoutine.status
                newRoutine.finishedStepCount = localRoutine.finishedStepCount
                newRoutine.days = localRoutine.days
                
                // Copy steps
                let localSteps = (localRoutine.steps ?? []).sorted(by: { $0.order < $1.order })
                for localStep in localSteps {
                    let newStep = Step(
                        name: localStep.name,
                        routine: newRoutine,
                        order: localStep.order,
                        days: localStep.days
                    )
                    newStep.status = localStep.status
                    if newRoutine.steps == nil {
                        newRoutine.steps = []
                    }
                    newRoutine.steps?.append(newStep)
                    cloudKitContext.insert(newStep)
                }
                
                cloudKitContext.insert(newRoutine)
            }
            
            // Save to CloudKit
            try cloudKitContext.save()
            print("Successfully migrated \(localRoutines.count) routines to CloudKit")
            
            // Mark migration as complete
            UserDefaults.standard.set(true, forKey: Self.migrationKey)
            
        } catch {
            print("Error during migration: \(error.localizedDescription)")
            // If local store doesn't exist or migration fails, mark as complete to avoid retrying
            UserDefaults.standard.set(true, forKey: Self.migrationKey)
        }
    }
}

// Helper view to handle scene phase changes for sync
private struct AppLifecycleSyncView<Content: View>: View {
    let syncObserver: CloudKitSyncObserver
    let content: Content
    @Environment(\.scenePhase) private var scenePhase
    
    init(syncObserver: CloudKitSyncObserver, @ViewBuilder content: () -> Content) {
        self.syncObserver = syncObserver
        self.content = content()
    }
    
    var body: some View {
        content
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // Trigger sync when app becomes active
                if newPhase == .active {
                    Task { @MainActor in
                        await syncObserver.fetchChanges()
                    }
                }
            }
    }
}

