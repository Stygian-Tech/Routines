//
//  LinkListCardView.swift
//  Routines
//
//  Created by Sam Clemente on 12/4/24.
//

import SwiftUI

struct LinkListCardView: View {
    var urlString: String
    var name: String
    
    var body: some View {
        Button(action: {
            guard let url = URL(string: urlString) else {
                return
            }
            UIApplication.shared.open(url)
        }) {
            HStack {
                Text(name)
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(name))
        .accessibilityHint(Text("Opens in Safari"))
    }
}
