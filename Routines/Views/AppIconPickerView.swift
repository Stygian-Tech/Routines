//
//  AppIconPickerView.swift
//  Routines
//
//  Created by AI on 2025-08-15.
//

import SwiftUI

struct AppIconPickerView: View {
    @StateObject private var manager = AppIconManager()
    @State private var showErrorAlert = false

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 96), spacing: 16, alignment: .top)]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(manager.availableOptions(), id: \.id) { option in
                    Button(action: { select(option) }) {
                        AppIconGridItem(
                            option: option,
                            isSelected: isSelected(option)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text("Sets the app icon to \(option.displayName)"))
                }
            }
            .padding(16)
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Unable to Change Icon", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(manager.lastError ?? "Unknown error")
        })
    }

    private func isSelected(_ option: AppIconOption) -> Bool {
        manager.currentAlternateIconName == option.alternateIconName || (option.alternateIconName == nil && manager.currentAlternateIconName == nil)
    }

    private func select(_ option: AppIconOption) {
        manager.setIcon(to: option) { _ in
            if manager.lastError != nil {
                showErrorAlert = true
            }
        }
    }
}


