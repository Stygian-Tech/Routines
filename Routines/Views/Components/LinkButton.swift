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
            HStack(spacing: 12) {
                if let systemName = symbol.sfSymbolName {
                    Image(systemName: systemName)
                        .foregroundStyle(symbol.color)
                        .frame(width: 22, height: 22)
                } else if let assetName = symbol.file, !assetName.isEmpty {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
                Text(symbol.name)
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(symbol.name))
        .accessibilityHint(Text("Opens in Safari"))
    }
}

