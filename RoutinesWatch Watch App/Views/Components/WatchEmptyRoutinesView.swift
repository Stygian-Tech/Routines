//
//  WatchEmptyRoutinesView.swift
//  RoutinesWatch
//
//  Created by AI on 12/19/24.
//

import SwiftUI

struct WatchEmptyRoutinesView: View {
    @Binding var showingAddRoutine: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Routines Today")
                .foregroundStyle(.secondary)
                .font(.headline)
            
            Button(action: {
                showingAddRoutine = true
            }) {
                Label("Create Routine", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .navigationTitle("Routines")
    }
}

