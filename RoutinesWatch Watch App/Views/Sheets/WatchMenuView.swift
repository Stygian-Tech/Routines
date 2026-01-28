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
                }) {
                    Label(showAllRoutines ? "Show Only Today" : "Show All Routines", systemImage: showAllRoutines ? "eye.slash" : "eye")
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
        }
    }
}

