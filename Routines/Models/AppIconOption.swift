//
//  AppIconOption.swift
//  Routines
//
//  Created by AI on 2025-08-15.
//

import Foundation
import SwiftUI
import UIKit

/// Represents an app icon choice. When `alternateIconName` is `nil`, this refers to the primary icon.
struct AppIconOption: Identifiable, Equatable {
    let id: String
    let displayName: String
    let alternateIconName: String?
    let previewColor: Color
    let previewImageName: String?

    init(displayName: String, alternateIconName: String?, previewColor: Color, previewImageName: String?) {
        self.id = alternateIconName ?? "primary"
        self.displayName = displayName
        self.alternateIconName = alternateIconName
        self.previewColor = previewColor
        self.previewImageName = previewImageName
    }
}

@MainActor
final class AppIconManager: ObservableObject {
    @Published private(set) var currentAlternateIconName: String?
    @Published var lastError: String?

    init() {
        if #available(iOS 10.3, *) {
            currentAlternateIconName = UIApplication.shared.alternateIconName
        } else {
            currentAlternateIconName = nil
        }
    }

    /// Returns the primary and alternate app icon options.
    /// Attempts to read from Info.plist (CFBundleIcons). If unavailable, falls back to a known list.
    func availableOptions(infoDictionary: [String: Any] = Bundle.main.infoDictionary ?? [:]) -> [AppIconOption] {
        // Primary icon first
        var options: [AppIconOption] = [
            // Use the bundled preview image for the primary icon if available
            AppIconOption(displayName: "Default", alternateIconName: nil, previewColor: .accentColor, previewImageName: "Royal Icon")
        ]

        // Try to parse alternates dynamically from Info.plist
        if let iconsDict = infoDictionary["CFBundleIcons"] as? [String: Any],
           let alternates = iconsDict["CFBundleAlternateIcons"] as? [String: Any] {
            let names = alternates.keys.sorted()
            for name in names {
                let mapped = AppIconManager.mapDisplay(for: name)
                options.append(mapped)
            }
            return options
        }

        // Fallback known set based on asset catalog naming
        let knownNames = [
            "AppIcon-Amber",
            "AppIcon-Deep",
            "AppIcon-Forest",
            "AppIcon-Goldenrod",
            "AppIcon-Jum",
            "AppIcon-Red",
            "AppIcon-Teal"
        ]
        for name in knownNames {
            options.append(AppIconManager.mapDisplay(for: name))
        }
        return options
    }

    private static func mapDisplay(for alternateIconName: String) -> AppIconOption {
        // Derive a user-friendly name and an approximate color for preview
        let lower = alternateIconName.lowercased()
        // Helper to build image name based on the option name (matches Assets.xcassets names like "Amber Icon")
        func imageName(for name: String) -> String { "\(name) Icon" }
        if lower.contains("amber") {
            return AppIconOption(displayName: "Amber", alternateIconName: alternateIconName, previewColor: .orange, previewImageName: imageName(for: "Amber"))
        }
        if lower.contains("deep") {
            return AppIconOption(displayName: "Deep", alternateIconName: alternateIconName, previewColor: Color(red: 0.12, green: 0.14, blue: 0.18), previewImageName: imageName(for: "Deep"))
        }
        if lower.contains("forest") {
            return AppIconOption(displayName: "Forest", alternateIconName: alternateIconName, previewColor: .green, previewImageName: imageName(for: "Forest"))
        }
        if lower.contains("goldenrod") {
            return AppIconOption(displayName: "Goldenrod", alternateIconName: alternateIconName, previewColor: Color(red: 0.85, green: 0.66, blue: 0.0), previewImageName: imageName(for: "Goldenrod"))
        }
        if lower.contains("jum") {
            return AppIconOption(displayName: "Jum", alternateIconName: alternateIconName, previewColor: Color(red: 0.36, green: 0.23, blue: 0.53), previewImageName: imageName(for: "Jum"))
        }
        if lower.contains("red") {
            return AppIconOption(displayName: "Red", alternateIconName: alternateIconName, previewColor: .red, previewImageName: imageName(for: "Red"))
        }
        if lower.contains("teal") {
            return AppIconOption(displayName: "Teal", alternateIconName: alternateIconName, previewColor: .teal, previewImageName: imageName(for: "Teal"))
        }
        // Default mapping if unknown
        let fallbackName = alternateIconName.replacingOccurrences(of: "AppIcon-", with: "")
        return AppIconOption(displayName: fallbackName, alternateIconName: alternateIconName, previewColor: .gray, previewImageName: imageName(for: fallbackName))
    }

    func setIcon(to option: AppIconOption, completion: (@Sendable (Error?) -> Void)? = nil) {
        guard #available(iOS 10.3, *) else {
            lastError = "Changing app icons requires iOS 10.3+."
            completion?(NSError(domain: "AppIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: lastError ?? "Unknown error"]))
            return
        }
        guard UIApplication.shared.supportsAlternateIcons else {
            lastError = "Alternate app icons are not supported."
            completion?(NSError(domain: "AppIcon", code: 2, userInfo: [NSLocalizedDescriptionKey: lastError ?? "Unknown error"]))
            return
        }

        UIApplication.shared.setAlternateIconName(option.alternateIconName) { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    self?.lastError = error.localizedDescription
                } else {
                    self?.lastError = nil
                    self?.currentAlternateIconName = UIApplication.shared.alternateIconName
                }
                completion?(error)
            }
        }
    }
}

