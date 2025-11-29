//
//  WatchMenuView.swift
//  RoutinesWatch
//
//  Created for watchOS menu options
//

import SwiftUI

struct WatchMenuView: View {
    @Binding var isPresented: Bool
    @Binding var showingAddRoutine: Bool
    @Binding var showAllRoutines: Bool
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
                
                Button(action: {
                    showAllRoutines.toggle()
                    isPresented = false
                }) {
                    Label(
                        showAllRoutines ? "Show Today's Routines" : "Show All Routines",
                        systemImage: showAllRoutines ? "calendar" : "list.number"
                    )
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

