//
//  LinkButton.swift
//  Routines
//
//  Created by Sam Clemente on 5/5/25.
//

import SwiftUI

struct LinkButton: View {
    var symbol: Symbol
    
    var body: some View {
        Button(action: {
            guard let url = URL(string: symbol.url) else {
                return
            }
            UIApplication.shared.open(url)
        }) {
            HStack {
                Image(symbol.file)
                    .foregroundStyle(symbol.color)
                Text(symbol.name)
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

