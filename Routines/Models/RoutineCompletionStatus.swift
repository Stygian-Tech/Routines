//
//  RoutineCompletionStatus.swift
//  Routines
//
//  Created by Sam Clemente on 8/28/24.
//

import Foundation

enum RoutineCompletionStatus: Int, Codable {
    case incomplete = 0
    case complete = 1
    case completeWithSkippedSteps = 2
    
    var icon: RoutineCompletionIcon {
        switch self {
        case .incomplete:
            return RoutineCompletionIcon.init(iconColor1: .clear)
        case .complete:
            return RoutineCompletionIcon.init(iconColor1: .green)
        case .completeWithSkippedSteps:
            return RoutineCompletionIcon.init(iconColor1: .green, iconColor2: .yellow)
        }
        
    }
}
