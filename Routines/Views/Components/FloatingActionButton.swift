//
//  FloatingActionButton.swift
//  Routines
//
//  Created by Sam Clemente on 4/8/25.
//

import SwiftUI

struct FloatingActionButton: View {
    var iconName: String = "plus"
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
                        Image(systemName: iconName)
                            .foregroundStyle(.white)
                            .font(.title2)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isPressed = false
                                    action()
                                }
                            }
                    )
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(iconName == "plus" ? "Add" : "Action"))
                    .accessibilityAddTraits(.isButton)
            }
            .padding(.trailing, 30)
            .padding(.bottom, 20)
        }
    }
} 