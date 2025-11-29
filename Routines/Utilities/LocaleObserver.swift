//
//  LocaleObserver.swift
//  Routines
//
//  Created by AI on 12/19/24.
//

import Foundation
import SwiftUI
import Combine

/// Observable object that tracks locale and calendar changes
/// Automatically updates when user changes system preferences like locale, calendar system, or week start day
@MainActor
class LocaleObserver: ObservableObject {
    @Published private(set) var localeIdentifier: String
    @Published private(set) var calendarIdentifier: String
    @Published private(set) var firstWeekday: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.localeIdentifier = Locale.current.identifier
        self.calendarIdentifier = String(describing: Calendar.current.identifier)
        self.firstWeekday = Calendar.current.firstWeekday
        
        // Observe locale changes (triggers when user changes language/region)
        NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateLocale()
                }
            }
            .store(in: &cancellables)
        
        // Observe when app becomes active (user may have changed settings while app was backgrounded)
        #if os(iOS)
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateLocale()
                }
            }
            .store(in: &cancellables)
        #endif
        
        // Also check periodically (in case notifications are missed)
        // Check every time the view appears or when explicitly requested
    }
    
    private func updateLocale() {
        let newLocale = Locale.current.identifier
        let newCalendar = String(describing: Calendar.current.identifier)
        let newFirstWeekday = Calendar.current.firstWeekday
        
        // Only update if something actually changed
        if newLocale != localeIdentifier || 
           newCalendar != calendarIdentifier || 
           newFirstWeekday != firstWeekday {
            localeIdentifier = newLocale
            calendarIdentifier = newCalendar
            firstWeekday = newFirstWeekday
            objectWillChange.send()
        }
    }
    
    /// Force refresh of locale/calendar settings
    /// Call this when you want to ensure the latest system preferences are reflected
    func refresh() {
        updateLocale()
    }
}

