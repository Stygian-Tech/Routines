//
//  DateUtility.swift
//  Routines
//
//  Created by AI on 12/19/24.
//

import Foundation

/// Utility class for date operations with calendar system and locale awareness
/// 
/// This utility automatically detects and uses the system's current calendar and locale settings.
/// It reads Calendar.current and Locale.current on each access, ensuring it always reflects
/// the latest user preferences including:
/// - Calendar system (Gregorian, Islamic, Hebrew, etc.)
/// - Locale/language settings
/// - Week start day preferences
/// 
/// When user changes system preferences, views using LocaleObserver will automatically refresh.
struct DateUtility {
    /// Current calendar system (detected from system settings)
    static var currentCalendar: Calendar {
        Calendar.current
    }
    
    /// Current locale (for formatting day names)
    static var currentLocale: Locale {
        Locale.current
    }
    
    /// First weekday according to system calendar (1=Sunday, 2=Monday, etc.)
    static var firstWeekday: Int {
        currentCalendar.firstWeekday
    }
    
    /// Get all weekdays ordered by system's week start preference
    static func allWeekdays() -> [Weekday] {
        let firstDay = firstWeekday
        var weekdays: [Weekday] = []
        
        // Start from first weekday and wrap around
        for i in 0..<7 {
            let dayValue = ((firstDay - 1 + i) % 7) + 1
            weekdays.append(Weekday(rawValue: dayValue))
        }
        
        return weekdays
    }
    
    /// Get display name for a weekday in the current locale
    static func displayName(for weekday: Weekday, style: DateFormatter.Style = .full) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.calendar = currentCalendar
        
        // Create a date representing the weekday
        // Use a known date and adjust to the target weekday
        let calendar = currentCalendar
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1
        
        // Get a reference date (January 1, 2024)
        guard let referenceDate = calendar.date(from: components) else {
            // Fallback: use weekday symbol
            return formatter.weekdaySymbols[weekday.calendarWeekday - 1]
        }
        
        // Find the first occurrence of this weekday
        let referenceWeekday = calendar.component(.weekday, from: referenceDate)
        let daysToAdd = (weekday.calendarWeekday - referenceWeekday + 7) % 7
        guard let date = calendar.date(byAdding: .day, value: daysToAdd, to: referenceDate) else {
            // Fallback: use weekday symbol
            return formatter.weekdaySymbols[weekday.calendarWeekday - 1]
        }
        
        // Set date format based on style
        // DateFormatter.Style cases: .none, .short, .medium, .long, .full
        formatter.dateFormat = switch style {
        case .none, .long, .full:
            "EEEE"  // Full weekday name
        case .short, .medium:
            "EEE"   // Abbreviated weekday name
        @unknown default:
            "EEEE"  // Default to full name
        }
        
        return formatter.string(from: date)
    }
    
    /// Get abbreviated display name (first letter or short form)
    static func abbreviatedDisplayName(for weekday: Weekday) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.calendar = currentCalendar
        formatter.dateFormat = "EEEEE" // Single letter
        
        let calendar = currentCalendar
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1
        
        // Get a reference date (January 1, 2024)
        guard let referenceDate = calendar.date(from: components) else {
            // Fallback: use first character of weekday name
            return String(displayName(for: weekday).prefix(1))
        }
        
        // Find the first occurrence of this weekday
        let referenceWeekday = calendar.component(.weekday, from: referenceDate)
        let daysToAdd = (weekday.calendarWeekday - referenceWeekday + 7) % 7
        guard let date = calendar.date(byAdding: .day, value: daysToAdd, to: referenceDate) else {
            // Fallback: use first character of weekday name
            return String(displayName(for: weekday).prefix(1))
        }
        
        return formatter.string(from: date)
    }
    
    /// Get today's weekday
    static func todayWeekday() -> Weekday {
        let calendar = currentCalendar
        let weekdayComponent = calendar.component(.weekday, from: Date())
        return Weekday(rawValue: weekdayComponent)
    }
    
    /// Check if a weekday matches today
    static func isToday(_ weekday: Weekday) -> Bool {
        todayWeekday() == weekday
    }
    
    /// Convert a weekday to today's date context
    static func dateForWeekday(_ weekday: Weekday, in referenceDate: Date = Date()) -> Date? {
        let calendar = currentCalendar
        let referenceWeekday = calendar.component(.weekday, from: referenceDate)
        let daysDifference = weekday.calendarWeekday - referenceWeekday
        
        return calendar.date(byAdding: .day, value: daysDifference, to: referenceDate)
    }
}

// MARK: - Migration Support

extension DateUtility {
    /// Convert a day name string to a Weekday (for migration from old string-based system)
    /// Supports multiple languages and formats
    static func weekdayFromString(_ dayString: String) -> Weekday? {
        let normalizedString = dayString.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Try current locale first
        if let weekday = weekdayFromStringInLocale(normalizedString, locale: currentLocale) {
            return weekday
        }
        
        // Try English locale as fallback (for old data)
        let englishLocale = Locale(identifier: "en_US")
        if let weekday = weekdayFromStringInLocale(normalizedString, locale: englishLocale) {
            return weekday
        }
        
        // Try common variations
        let dayNameMap: [String: Int] = [
            "sunday": 1, "sun": 1, "domingo": 1, "dimanche": 1, "sonntag": 1,
            "monday": 2, "mon": 2, "lunes": 2, "lundi": 2, "montag": 2,
            "tuesday": 3, "tue": 3, "martes": 3, "mardi": 3, "dienstag": 3,
            "wednesday": 4, "wed": 4, "miércoles": 4, "mercredi": 4, "mittwoch": 4,
            "thursday": 5, "thu": 5, "jueves": 5, "jeudi": 5, "donnerstag": 5,
            "friday": 6, "fri": 6, "viernes": 6, "vendredi": 6, "freitag": 6,
            "saturday": 7, "sat": 7, "sábado": 7, "samedi": 7, "samstag": 7
        ]
        
        if let weekdayValue = dayNameMap[normalizedString] {
            return Weekday(rawValue: weekdayValue)
        }
        
        return nil
    }
    
    /// Convert day name string using a specific locale
    private static func weekdayFromStringInLocale(_ dayString: String, locale: Locale) -> Weekday? {
        let formatter = DateFormatter()
        formatter.locale = locale
        // Use Gregorian calendar as default (most common)
        // The locale will handle the formatting appropriately
        formatter.calendar = Calendar(identifier: .gregorian)
        
        // Try full weekday names
        formatter.dateFormat = "EEEE"
        for (index, symbol) in formatter.weekdaySymbols.enumerated() {
            if symbol.lowercased() == dayString {
                return Weekday(rawValue: index + 1)
            }
        }
        
        // Try short weekday names
        formatter.dateFormat = "EEE"
        for (index, symbol) in formatter.shortWeekdaySymbols.enumerated() {
            if symbol.lowercased() == dayString {
                return Weekday(rawValue: index + 1)
            }
        }
        
        // Try very short weekday names
        formatter.dateFormat = "EEEEE"
        for (index, symbol) in formatter.veryShortWeekdaySymbols.enumerated() {
            if symbol.lowercased() == dayString {
                return Weekday(rawValue: index + 1)
            }
        }
        
        return nil
    }
    
    /// Convert array of day name strings to weekday array (for migration)
    static func weekdaysFromStrings(_ dayStrings: [String]) -> [Weekday] {
        var weekdays: Set<Weekday> = []
        
        for dayString in dayStrings {
            if let weekday = weekdayFromString(dayString) {
                weekdays.insert(weekday)
            }
        }
        
        // If no valid weekdays found, return all weekdays as default
        if weekdays.isEmpty {
            return allWeekdays()
        }
        
        // Return sorted by calendar order
        return weekdays.sorted()
    }
}

