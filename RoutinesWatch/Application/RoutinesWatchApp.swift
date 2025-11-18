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
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            WatchRoutineListView()
        }
        .modelContainer(container)
    }
}
