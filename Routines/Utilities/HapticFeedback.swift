//
//  HapticFeedback.swift
//  Routines
//
//  Created for haptic feedback utilities
//

import UIKit

/// Utility for providing haptic feedback throughout the app
enum HapticFeedback {
    /// Light impact feedback - for subtle interactions like toggling
    @MainActor
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact feedback - for standard interactions like selecting
    @MainActor
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy impact feedback - for important interactions like completing steps
    @MainActor
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Error feedback - for when an action cannot be performed
    @MainActor
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Success feedback - for successful actions
    @MainActor
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning feedback - for warnings
    @MainActor
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

