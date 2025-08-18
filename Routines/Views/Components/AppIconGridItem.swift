//
//  AppIconGridItem.swift
//  Routines
//
//  Created by AI on 2025-08-15.
//

import SwiftUI
import UIKit

struct AppIconGridItem: View {
    let option: AppIconOption
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(option.previewColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Group {
                            if let imageName = option.previewImageName, UIImage(named: imageName) != nil {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            } else {
                                Image(systemName: "app.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .accessibilityHidden(true)

            Text(option.displayName)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(option.displayName))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}


