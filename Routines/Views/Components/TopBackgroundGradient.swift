//
//  TopBackgroundGradient.swift
//  Routines
//
//  Reusable top-aligned background gradient similar to Sports/Journal
//

import SwiftUI

struct TopBackgroundGradient: View {
    var color: Color = .accentColor
    var height: CGFloat = 300
    
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: color.opacity(0.55), location: 0.0),
                .init(color: color.opacity(0.22), location: 0.25),
                .init(color: .clear, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}


