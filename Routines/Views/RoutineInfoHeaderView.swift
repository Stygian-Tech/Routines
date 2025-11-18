//
//  RoutineInfoHeaderView.swift
//  Routines
//
//  Created by Sam Clemente on 5/5/25.
//

import SwiftUI

struct RoutineInfoHeaderView: View {
    let routine: Routine
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .accessibilityHidden(true)
            Text(routine.timeToString())
            Spacer()
        } // HStack
        .padding(.leading)
    }
}
