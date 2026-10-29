//
//  WidgetSnapshot.swift
//  PawprintWidgetShared
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Everything the widgets need to draw themselves, written by the app and
//  read by the widgets: upcoming tasks and health follow-ups (soonest
//  first, so overdue ones come first), a week of daily Learn tips, and how
//  many dogs there are (the widget only shows dog names when there is more
//  than one).
//

import Foundation

nonisolated struct WidgetTip: Codable, Hashable, Identifiable, Sendable {
    let contentID: String
    let title: String
    let summary: String
    let categoryTitle: String
    let categoryImage: String
    /// Start of the day this tip is shown.
    let day: Date

    var id: String { "\(contentID)|\(day.timeIntervalSince1970)" }

    var deepLink: PawprintDeepLink { .learn(tipID: contentID) }
}

nonisolated struct WidgetSnapshot: Codable, Equatable, Sendable {
    var generatedAt: Date
    var tasks: [UpcomingTask]
    var tips: [WidgetTip]
    var dogCount: Int

    init(generatedAt: Date, tasks: [UpcomingTask], tips: [WidgetTip] = [], dogCount: Int = 1) {
        self.generatedAt = generatedAt
        self.tasks = tasks
        self.tips = tips
        self.dogCount = dogCount
    }

    // Snapshots saved before tips and dogCount existed have neither key, so
    // they fall back to defaults instead of failing to decode.
    private enum CodingKeys: String, CodingKey {
        case generatedAt, tasks, tips, dogCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        generatedAt = try container.decode(Date.self, forKey: .generatedAt)
        tasks = try container.decode([UpcomingTask].self, forKey: .tasks)
        tips = try container.decodeIfPresent([WidgetTip].self, forKey: .tips) ?? []
        dogCount = try container.decodeIfPresent(Int.self, forKey: .dogCount) ?? 1
    }

    static let empty = WidgetSnapshot(generatedAt: .distantPast, tasks: [])

    var showsDogNames: Bool { dogCount > 1 }

    func overdueCount(at now: Date) -> Int {
        tasks.filter { $0.dueDate < now }.count
    }

    /// The tip planned for the day of `date`, or the first one if that day isn't planned.
    func tip(on date: Date, calendar: Calendar = .current) -> WidgetTip? {
        tips.first { calendar.isDate($0.day, inSameDayAs: date) } ?? tips.first
    }

    /// A copy without the routine tasks with these ids. Used to hide a task the
    /// moment it is ticked off in the widget, before the app has caught up.
    func removing(taskIDs: Set<String>) -> WidgetSnapshot {
        guard !taskIDs.isEmpty else { return self }
        var copy = self
        copy.tasks.removeAll { task in
            guard let id = task.taskID else { return false }
            return taskIDs.contains(id)
        }
        return copy
    }

    /// Ignores `generatedAt`, so a refresh that changes nothing visible can be skipped.
    func hasSameContent(as other: WidgetSnapshot) -> Bool {
        tasks == other.tasks && tips == other.tips && dogCount == other.dogCount
    }
}
