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

    init(displayName: String, alternateIconName: String?, previewColor: Color) {
        self.id = alternateIconName ?? "primary"
        self.displayName = displayName
        self.alternateIconName = alternateIconName
        self.previewColor = previewColor
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
            AppIconOption(displayName: "Default", alternateIconName: nil, previewColor: .accentColor)
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
        if lower.contains("amber") {
            return AppIconOption(displayName: "Amber", alternateIconName: alternateIconName, previewColor: .orange)
        }
        if lower.contains("deep") {
            return AppIconOption(displayName: "Deep", alternateIconName: alternateIconName, previewColor: Color(red: 0.12, green: 0.14, blue: 0.18))
        }
        if lower.contains("forest") {
            return AppIconOption(displayName: "Forest", alternateIconName: alternateIconName, previewColor: .green)
        }
        if lower.contains("goldenrod") {
            return AppIconOption(displayName: "Goldenrod", alternateIconName: alternateIconName, previewColor: Color(red: 0.85, green: 0.66, blue: 0.0))
        }
        if lower.contains("jum") {
            return AppIconOption(displayName: "Jum", alternateIconName: alternateIconName, previewColor: Color(red: 0.36, green: 0.23, blue: 0.53))
        }
        if lower.contains("red") {
            return AppIconOption(displayName: "Red", alternateIconName: alternateIconName, previewColor: .red)
        }
        if lower.contains("teal") {
            return AppIconOption(displayName: "Teal", alternateIconName: alternateIconName, previewColor: .teal)
        }
        // Default mapping if unknown
        return AppIconOption(displayName: alternateIconName.replacingOccurrences(of: "AppIcon-", with: ""), alternateIconName: alternateIconName, previewColor: .gray)
    }

    func setIcon(to option: AppIconOption, completion: ((Error?) -> Void)? = nil) {
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


