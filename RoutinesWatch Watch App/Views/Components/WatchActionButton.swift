//
//  WatchActionButton.swift
//  RoutinesWatch
//
//  Created to reduce code repetition for action buttons
//

import SwiftUI

struct WatchActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    var tint: Color? = nil
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(tint)
    }
}

