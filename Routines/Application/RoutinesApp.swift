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

@main
struct RoutinesApp: App {
    var resetTipsOnLaunch = true
    let container: ModelContainer
    private var isUITestSeedEnabled: Bool { ProcessInfo.processInfo.arguments.contains("UI_TEST_SEED") }
    
    init() {
        do {
            container = try ModelContainer(for: Routine.self, Step.self)
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
            RoutineListView()
                .onAppear(perform: promptForNotifications)
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
                routine.days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
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
}
