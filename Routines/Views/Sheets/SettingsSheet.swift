//
//  SettingsSheet.swift
//  Routines
//
//  Created to modularize sheets
//

import SwiftUI

struct SettingsSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            SettingsView(isPresented: $isPresented)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: { isPresented = false }) {
                            Text("Done")
                        }
                    }
                }
        }
    }
}


