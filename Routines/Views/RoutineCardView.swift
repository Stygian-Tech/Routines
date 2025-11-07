//
//  RoutineCardView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct RoutineCardView: View {
    var routine: Routine
    
    var body: some View {
        // Core card content
        let content = VStack {
            HStack{
                VStack {
                    HStack {
                        RoutineIconView(routine: routine)
                        Spacer()
                    }
                    HStack {
                        Text(routine.name)
                            .font(.headline)
                        if routine.isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        Spacer()
                    }
                }
            }
            HStack {
                Image(systemName: "list.bullet")
                Text("\(routine.steps.count) steps")
                Spacer()
                Text("\(routine.timeToString())")
                Image(systemName: "clock")
            }
            .padding(.horizontal)
        }
        .padding()

        Group {
            if #available(iOS 18.0, *) {
                content
                    .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                content
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
        }
    }
}

#Preview {
    RoutineCardView(routine: Routine())
}
