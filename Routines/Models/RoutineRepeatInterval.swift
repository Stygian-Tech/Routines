//
//  RoutineRepeatInterval.swift
//  Routines
//
//  Created by Codex on 2/8/26.
//

import Foundation

enum RoutineRepeatInterval: String, CaseIterable, Codable, Identifiable {
    case weekly
    case fortnightly
    case monthly
    case biMonthly
    case quarterly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .fortnightly:
            return "Every Other Week"
        case .monthly:
            return "Monthly"
        case .biMonthly:
            return "Every Other Month"
        case .quarterly:
            return "Quarterly"
        case .yearly:
            return "Yearly"
        }
    }

    var weekInterval: Int? {
        switch self {
        case .weekly:
            return 1
        case .fortnightly:
            return 2
        default:
            return nil
        }
    }

    var monthInterval: Int? {
        switch self {
        case .monthly:
            return 1
        case .biMonthly:
            return 2
        case .quarterly:
            return 3
        case .yearly:
            return 12
        default:
            return nil
        }
    }

    /// Cadences longer than one week use `repeatAnchorDate` (start of day) as the first day the routine may appear.
    var usesLongCycleStartDate: Bool {
        switch self {
        case .weekly:
            return false
        case .fortnightly, .monthly, .biMonthly, .quarterly, .yearly:
            return true
        }
    }
}
