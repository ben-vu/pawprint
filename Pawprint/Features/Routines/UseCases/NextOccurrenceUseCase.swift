//
//  NextOccurrenceUseCase.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
//
//  Works out when a repeating task is due next. Steps forward by whole
//  days so the time of day stays the same across daylight saving, and
//  skips any occurrences that were missed while the app was closed.
//

import Foundation

struct NextOccurrenceUseCase {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// The first repeat of `dueDate` that falls today or later, or nil for a one-off task.
    /// `weekdays` is used by .weekdays and `everyWeeks` by .everyFewWeeks.
    func execute(
        after dueDate: Date,
        recurrence: RoutineRecurrence,
        weekdays: Set<Int> = [],
        everyWeeks: Int = 2,
        today: Date = .now
    ) -> Date? {
        if recurrence == .once { return nil }
        if recurrence == .weekdays && weekdays.isEmpty { return nil }
        let startOfToday = calendar.startOfDay(for: today)

        var next = dueDate
        repeat {
            guard let date = step(from: next, recurrence: recurrence, weekdays: weekdays, everyWeeks: everyWeeks) else { return nil }
            next = date
        } while next < startOfToday
        return next
    }

    /// One repeat after `date`.
    private func step(from date: Date, recurrence: RoutineRecurrence, weekdays: Set<Int>, everyWeeks: Int) -> Date? {
        switch recurrence {
        case .once:
            return nil
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: date)
        case .everyFewWeeks:
            return calendar.date(byAdding: .day, value: 7 * everyWeeks, to: date)
        case .twiceDaily:
            // Alternates between the chosen time and 12 hours later, by clock time.
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            if hour < 12 {
                return calendar.date(bySettingHour: hour + 12, minute: minute, second: 0, of: date)
            }
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else { return nil }
            return calendar.date(bySettingHour: hour - 12, minute: minute, second: 0, of: tomorrow)
        case .weekdays:
            // The next day, at the same time, that is one of the chosen weekdays.
            var candidate = date
            for _ in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: 1, to: candidate) else { return nil }
                candidate = date
                if weekdays.contains(calendar.component(.weekday, from: candidate)) { return candidate }
            }
            return nil
        }
    }
}
