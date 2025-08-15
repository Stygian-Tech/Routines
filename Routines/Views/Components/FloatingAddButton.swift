//
//  FloatingAddButton.swift
//  Routines
//
//  Created by Sam Clemente on 5/5/25.
//

import SwiftUI

struct FloatingAddButton: View {
    var color: Color = .accentColor
    @Binding var isPressed: Bool
    var action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Circle()
                    .fill(isPressed ? color.opacity(0.7) : color)
                    .frame(width: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.title2)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isPressed = true
                                } // withAnimation
                            } // onChanged
                            .onEnded { _ in
                                withAnimation {
                                    isPressed = false
                                    action()
                                } // withAnimation
                            } // onEnded
                    )
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("Add"))
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint(Text("Adds a new item"))
            } // HStack
            .padding(.trailing, 30)
            .padding(.bottom, 20)
        } // VStack
    }
}

