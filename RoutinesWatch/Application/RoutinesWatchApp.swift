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
            
            // Log CloudKit configuration for debugging
            print("WatchOS: ModelContainer initialized with CloudKit")
            print("WatchOS: Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            WatchRoutineListView()
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
        }
        .modelContainer(container)
    }
}
