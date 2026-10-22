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
    func execute(after dueDate: Date, recurrence: RoutineRecurrence, today: Date = .now) -> Date? {
        guard let step = recurrence.dayInterval else { return nil }
        let startOfToday = calendar.startOfDay(for: today)

        var next = dueDate
        repeat {
            guard let date = calendar.date(byAdding: .day, value: step, to: next) else { return nil }
            next = date
        } while next < startOfToday
        return next
    }
}
