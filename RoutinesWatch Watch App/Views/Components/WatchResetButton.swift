//
//  WatchResetButton.swift
//  RoutinesWatch
//
//  Created for modularizing reset button functionality
//

import SwiftUI
import SwiftData

/// A reusable reset button component for watchOS
struct WatchResetButton: View {
    let action: () -> Void
    let label: String
    let systemImage: String
    let tint: Color?
    
    /// Creates a reset button with custom styling
    /// - Parameters:
    ///   - action: The action to perform when the button is tapped
    ///   - label: The text label for the button
    ///   - systemImage: The SF Symbol name for the button icon
    ///   - tint: Optional color tint for the button (defaults to red for destructive appearance)
    init(
        action: @escaping () -> Void,
        label: String = "Reset",
        systemImage: String = "arrow.circlepath",
        tint: Color? = .red
    ) {
        self.action = action
        self.label = label
        self.systemImage = systemImage
        self.tint = tint
    }
    
    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
    }
}

/// Helper function to reset a single routine
/// - Parameters:
///   - routine: The routine to reset
///   - routineManager: The RoutineManager instance
///   - onCompletion: Optional completion handler called after successful reset
@MainActor
func resetRoutine(
    _ routine: Routine,
    using routineManager: RoutineManager,
    onCompletion: (() -> Void)? = nil
) async {
    do {
        try await routineManager.resetRoutine(routine)
        try await routineManager.save()
        onCompletion?()
    } catch {
        print("Error resetting routine: \(error.localizedDescription)")
    }
}

/// Helper function to reset multiple routines
/// - Parameters:
///   - routines: The routines to reset
///   - routineManager: The RoutineManager instance
///   - onCompletion: Optional completion handler called after successful reset
@MainActor
func resetRoutines(
    _ routines: [Routine],
    using routineManager: RoutineManager,
    onCompletion: (() async throws -> Void)? = nil
) async {
    do {
        try await routineManager.resetRoutines(routines)
        try await routineManager.save()
        try await onCompletion?()
    } catch {
        print("Error resetting routines: \(error.localizedDescription)")
    }
}

