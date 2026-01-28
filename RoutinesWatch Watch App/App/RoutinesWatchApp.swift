//
//  RoutinesWatchApp.swift
//  RoutinesWatch
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData

@main
struct RoutinesWatchApp: App {
    let container: ModelContainer
    private let cloudKitSyncObserver: CloudKitSyncObserver
    private let cloudKitSubscriptionManager: CloudKitSubscriptionManager
    
    init() {
        do {
            // Configure schema with Routine and Step models
            let schema = Schema([Routine.self, Step.self])
            
            // Configure ModelConfiguration with CloudKit for sync
            // Using .automatic will use the iCloud container configured in Xcode
            // Both iOS and watchOS apps must be configured to use the same iCloud container in Xcode
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Set up CloudKit sync observer for real-time updates
            cloudKitSyncObserver = CloudKitSyncObserver(container: container)
            
            // Set up CloudKit subscription manager for push notifications
            cloudKitSubscriptionManager = CloudKitSubscriptionManager()
            
            // Log CloudKit configuration for debugging
            print("WatchOS: ModelContainer initialized with CloudKit")
            print("WatchOS: Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppLifecycleSyncView(syncObserver: cloudKitSyncObserver) {
                WatchRoutineListView()
                    .task {
                        // Set up CloudKit subscription for push notifications
                        await cloudKitSubscriptionManager.setupSubscription()
                    }
                    .onAppear {
                        // Check initial data count and force a refresh after delays to allow CloudKit sync
                        Task { [container] in
                            let context = ModelContext(container)
                            
                            // Check initial count
                            do {
                                let initialRoutines: [Routine] = try context.fetch(FetchDescriptor<Routine>())
                                print("WatchOS: Initial routine count: \(initialRoutines.count)")
                            } catch {
                                print("WatchOS: Error fetching routines: \(error)")
                            }
                            
                            // Wait and check again (CloudKit sync can take time)
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                            do {
                                let routines: [Routine] = try context.fetch(FetchDescriptor<Routine>())
                                print("WatchOS: Routine count after 2s delay: \(routines.count)")
                            } catch {
                                print("WatchOS: Error fetching routines after delay: \(error)")
                            }
                            
                            // Wait longer and check again (CloudKit can take 5-10 seconds)
                            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 more seconds
                            do {
                                let routines: [Routine] = try context.fetch(FetchDescriptor<Routine>())
                                print("WatchOS: Routine count after 7s total delay: \(routines.count)")
                                
                                if routines.isEmpty {
                                    print("WatchOS: WARNING - Still no routines after 7 seconds")
                                    print("WatchOS: This may indicate:")
                                    print("WatchOS: 1. iOS and watchOS apps are using different CloudKit containers")
                                    print("WatchOS: 2. CloudKit sync is taking longer than expected")
                                    print("WatchOS: 3. Data hasn't been uploaded to CloudKit from iOS app yet")
                                }
                            } catch {
                                print("WatchOS: Error fetching routines after longer delay: \(error)")
                            }
                        }
                    }
                    .environmentObject(cloudKitSyncObserver)
            }
        }
        .modelContainer(container)
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

