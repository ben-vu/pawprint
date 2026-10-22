//
//  UpcomingTask.swift
//  PawprintWidgetShared
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  A small, plain copy of a routine task that is safe to store in the App
//  Group and show in a widget. The widget never touches SwiftData.
//

import Foundation

nonisolated enum UpcomingTaskStatus: Sendable, Equatable {
    case overdue
    case dueToday
    case upcoming
}

nonisolated struct UpcomingTask: Codable, Hashable, Identifiable, Sendable {
    let title: String
    let dueDate: Date
    let dogName: String?

    var id: String { "\(title)|\(dueDate.timeIntervalSince1970)" }

    /// Where this task sits relative to `now`.
    func status(at now: Date, calendar: Calendar = .current) -> UpcomingTaskStatus {
        if dueDate < now { return .overdue }
        if calendar.isDate(dueDate, inSameDayAs: now) { return .dueToday }
        return .upcoming
    }

    /// Short text for the widget: "Overdue", a time today, "Tomorrow" or a weekday.
    func dueLabel(at now: Date, calendar: Calendar = .current) -> String {
        switch status(at: now, calendar: calendar) {
        case .overdue:
            return "Overdue"
        case .dueToday:
            return dueDate.formatted(date: .omitted, time: .shortened)
        case .upcoming:
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
               calendar.isDate(dueDate, inSameDayAs: tomorrow) {
                return "Tomorrow"
            }
            return dueDate.formatted(.dateTime.weekday(.abbreviated).day())
        }
    }
}
