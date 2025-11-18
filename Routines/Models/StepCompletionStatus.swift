//
//  StepCompletionStatus.swift
//  Routines
//
//  Created by Sam Clemente on 8/28/24.
//

import Foundation

enum StepCompletionStatus: Int, Codable {
    case incomplete = 0
    case complete = 1
    case skipped = 2
    
    var icon: String {
        switch self {
        case .incomplete:
            return "circle"
        case .complete:
            return "checkmark.circle.fill"
        case .skipped:
            return "circle.slash"
        }
    }
}
