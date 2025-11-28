//
//  Weekday.swift
//  Routines
//
//  Created by AI on 12/19/24.
//

import Foundation

/// Represents a weekday using calendar-agnostic integer values (1-7)
/// where 1 represents the first day of the week according to the system calendar
struct Weekday: Codable, Hashable, Comparable, Identifiable {
    /// Integer value representing the weekday (1-7)
    /// 1 = first day of week per system calendar (e.g., Sunday in US, Monday in many European locales)
    let rawValue: Int
    
    /// Unique identifier for SwiftUI/Identifiable conformance
    var id: Int { rawValue }
    
    init(rawValue: Int) {
        // Normalize to 1-7 range
        let normalized = ((rawValue - 1) % 7) + 1
        self.rawValue = normalized < 1 ? normalized + 7 : normalized
    }
    
    /// Initialize from Calendar weekday component (1=Sunday, 2=Monday, ..., 7=Saturday)
    init(calendarWeekday: Int) {
        self.init(rawValue: calendarWeekday)
    }
    
    /// Initialize from ISO weekday (1=Monday, 2=Tuesday, ..., 7=Sunday)
    init(isoWeekday: Int) {
        // Convert ISO weekday (Mon=1, Sun=7) to Calendar weekday (Sun=1, Mon=2)
        let calendarWeekday = isoWeekday == 7 ? 1 : isoWeekday + 1
        self.init(rawValue: calendarWeekday)
    }
    
    /// Get Calendar weekday component (1=Sunday, 2=Monday, ..., 7=Saturday)
    var calendarWeekday: Int {
        rawValue
    }
    
    /// Get ISO weekday (1=Monday, 2=Tuesday, ..., 7=Sunday)
    var isoWeekday: Int {
        rawValue == 1 ? 7 : rawValue - 1
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        self.init(rawValue: value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - Convenience Extensions

extension Weekday {
    /// All weekdays in calendar order (Sunday=1 through Saturday=7)
    static let allWeekdays: [Weekday] = (1...7).map { Weekday(rawValue: $0) }
}

