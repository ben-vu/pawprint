//
//  UpcomingTask.swift
//  PawprintWidgetShared
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  A small, plain copy of something coming up for a dog (a routine task or
//  a health follow-up) that is safe to store in the App Group and show in
//  a widget. The widget never touches SwiftData.
//

import Foundation

nonisolated enum UpcomingTaskKind: String, Codable, Sendable {
    case routine
    case health

    var systemImage: String {
        switch self {
        case .routine: return "checklist"
        case .health: return "cross.case.fill"
        }
    }
}

nonisolated enum UpcomingTaskStatus: Sendable, Equatable {
    case overdue
    case dueToday
    case upcoming
}

nonisolated struct UpcomingTask: Codable, Hashable, Identifiable, Sendable {
    let title: String
    let dueDate: Date
    let dogName: String?
    let kind: UpcomingTaskKind

    init(title: String, dueDate: Date, dogName: String? = nil, kind: UpcomingTaskKind = .routine) {
        self.title = title
        self.dueDate = dueDate
        self.dogName = dogName
        self.kind = kind
    }

    var id: String { "\(kind.rawValue)|\(title)|\(dogName ?? "")|\(dueDate.timeIntervalSince1970)" }

    /// Where tapping this in the widget should go.
    var deepLink: PawprintDeepLink {
        switch kind {
        case .routine: return .routines
        case .health: return .health
        }
    }

    /// Where this sits relative to `now`.
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
            return kind == .health ? "Today" : dueDate.formatted(date: .omitted, time: .shortened)
        case .upcoming:
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
               calendar.isDate(dueDate, inSameDayAs: tomorrow) {
                return "Tomorrow"
            }
            return dueDate.formatted(.dateTime.weekday(.abbreviated).day())
        }
    }
}
