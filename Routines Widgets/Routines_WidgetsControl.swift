//
//  Routines_WidgetsControl.swift
//  Routines Widgets
//
//  Created by Sam Clemente on 9/15/24.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct Routines_WidgetsControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.sam-clemente.routines-app.Routines-Widgets"
        ) {
            ControlWidgetButton(
                action: LaunchAppIntent()
            ) {
                Label("Open Routines", systemImage: "checklist")
            }
        }
        .displayName("Open Routines")
        .description("Opens Routines App")
    }
}

@available(iOS 18.0, *)
struct LaunchAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Routines"

    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
