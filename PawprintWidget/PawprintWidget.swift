//
//  PawprintWidget.swift
//  PawprintWidget
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  The Upcoming tasks widget.
//
//  The scenario it is built for: a new dog owner glances at their phone and
//  wants to know "what do I need to do for the dog next?" without opening
//  the app. The Home Screen sizes show the next few tasks and flag overdue
//  ones; the Lock Screen sizes show just the next task.
//
//  Data comes from a snapshot the app writes into the App Group (see
//  WidgetSyncService in the app target). The widget never opens the app's
//  database.
//

import WidgetKit
import SwiftUI

struct PawprintWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetConfig.widgetKind, provider: UpcomingTasksProvider()) { entry in
            UpcomingTasksWidgetView(entry: entry)
                .containerBackground(WidgetPalette.background, for: .widget)
        }
        .configurationDisplayName("Upcoming tasks")
        .description("See the next walks, meals and care tasks due for your dog.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - The data

struct UpcomingTasksEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot

    var tasks: [UpcomingTask] { snapshot.tasks }
    var overdueCount: Int { snapshot.overdueCount(at: date) }

    /// Made-up tasks for the widget gallery and previews, so it looks real
    /// before the person has added anything.
    static var sample: UpcomingTasksEntry {
        let now = Date()
        return UpcomingTasksEntry(
            date: now,
            snapshot: WidgetSnapshot(
                generatedAt: now,
                tasks: [
                    UpcomingTask(title: "Brush coat", dueDate: now.addingTimeInterval(-60 * 60), dogName: "Biscuit", category: "grooming"),
                    UpcomingTask(title: "Evening walk", dueDate: now.addingTimeInterval(45 * 60), dogName: "Biscuit", category: "walk"),
                    UpcomingTask(title: "Dinner", dueDate: now.addingTimeInterval(3 * 60 * 60), dogName: "Biscuit", category: "meal"),
                    UpcomingTask(title: "Flea treatment", dueDate: now.addingTimeInterval(26 * 60 * 60), dogName: "Biscuit", category: "medication")
                ]
            )
        )
    }
}

struct UpcomingTasksProvider: TimelineProvider {
    private let store: WidgetSnapshotStore = AppGroupWidgetSnapshotStore()

    func placeholder(in context: Context) -> UpcomingTasksEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingTasksEntry) -> Void) {
        let snapshot = store.load()
        if context.isPreview && snapshot.tasks.isEmpty {
            completion(.sample)
        } else {
            completion(UpcomingTasksEntry(date: Date(), snapshot: snapshot))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingTasksEntry>) -> Void) {
        let snapshot = store.load()
        let now = Date()

        // One entry now, one just after each future due date (so "due" flips to
        // "overdue" on time) and one at midnight (so "Tomorrow" becomes a time).
        var dates: [Date] = [now]
        dates += snapshot.tasks
            .map { $0.dueDate.addingTimeInterval(1) }
            .filter { $0 > now }
        if let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) {
            dates.append(midnight)
        }

        let entries = Set(dates)
            .sorted()
            .prefix(12)
            .map { UpcomingTasksEntry(date: $0, snapshot: snapshot) }

        completion(Timeline(entries: Array(entries), policy: .atEnd))
    }
}

#Preview(as: .systemSmall) {
    PawprintWidget()
} timeline: {
    UpcomingTasksEntry.sample
    UpcomingTasksEntry(date: Date(), snapshot: .empty)
}

#Preview(as: .systemMedium) {
    PawprintWidget()
} timeline: {
    UpcomingTasksEntry.sample
}

#Preview(as: .accessoryRectangular) {
    PawprintWidget()
} timeline: {
    UpcomingTasksEntry.sample
}

#Preview(as: .accessoryInline) {
    PawprintWidget()
} timeline: {
    UpcomingTasksEntry.sample
}
