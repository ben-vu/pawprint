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
    /// The routine's category raw value ("walk", "meal", ...), used to pick
    /// its icon. Nil for health follow-ups and for snapshots saved before
    /// it existed.
    let category: String?
    let kind: UpcomingTaskKind

    init(
        title: String,
        dueDate: Date,
        dogName: String? = nil,
        category: String? = nil,
        kind: UpcomingTaskKind = .routine
    ) {
        self.title = title
        self.dueDate = dueDate
        self.dogName = dogName
        self.category = category
        self.kind = kind
    }

    // Snapshots saved by older versions have no `category` or `kind`, so
    // both fall back to defaults instead of failing to decode.
    private enum CodingKeys: String, CodingKey {
        case title, dueDate, dogName, category, kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        dogName = try container.decodeIfPresent(String.self, forKey: .dogName)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        kind = try container.decodeIfPresent(UpcomingTaskKind.self, forKey: .kind) ?? .routine
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

