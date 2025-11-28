//
//  WatchMenuView.swift
//  RoutinesWatch
//
//  Created for watchOS menu options
//

import SwiftUI

enum MenuOption {
    case addRoutine
    case resetAllRoutines
}

struct WatchMenuView: View {
    @Binding var isPresented: Bool
    @Binding var showingAddRoutine: Bool
    var onResetSelected: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    showingAddRoutine = true
                    isPresented = false
                }) {
                    Label("Add Routine", systemImage: "plus")
                }
                
                Button(role: .destructive, action: {
                    onResetSelected()
                    isPresented = false
                }) {
                    Label("Reset All Routines", systemImage: "arrow.circlepath")
                }
            }
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

