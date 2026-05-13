//
//  UnitTestModelContainer.swift
//  Routines
//

import SwiftData

/// When running hosted (`Routines.app` + `RoutinesTests`), SwiftData must use a single `ModelContainer` for the process.
/// Creating additional containers in tests triggers Core Data + CloudKit mirroring teardown and stalls the test runner.
enum UnitTestModelContainer {
    /// Assigned from `RoutinesApp` when `UnitTestRuntime.isActive`.
    nonisolated(unsafe) static var shared: ModelContainer?

    enum TestSupportError: Error {
        case missingSharedContainer
    }

    /// New `ModelContext` sharing the app’s in-memory store, with all persisted routines removed.
    static func makeFreshContext() throws -> ModelContext {
        guard let shared else {
            throw TestSupportError.missingSharedContainer
        }
        let context = ModelContext(shared)
        try resetAllRoutines(in: context)
        return context
    }

    static func resetAllRoutines(in context: ModelContext) throws {
        let routines = try context.fetch(FetchDescriptor<Routine>())
        routines.forEach { context.delete($0) }
        if context.hasChanges {
            try context.save()
        }
    }
}
