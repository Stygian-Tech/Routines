//
//  RoutineInfoHeader.swift
//  Routines
//
//  Created by Sam Clemente on 4/8/25.
//

import SwiftUI

struct RoutineInfoHeader: View {
    let routine: Routine
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
            Text(routine.timeToString())
            Spacer()
        }
        .padding(.leading)
    }
} 