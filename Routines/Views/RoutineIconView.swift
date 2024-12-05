//
//  RoutineIconView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct RoutineIconView: View {
    var routine: Routine
    
    var body: some View {
        Circle()
            .fill(routine.getIconColor())
            .frame(width: 42)
            .overlay(
                Image(systemName: routine.iconSymbol)
                    .foregroundStyle(.white)
            )
    }
}
