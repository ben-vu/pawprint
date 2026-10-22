//
//  PawprintTimeline.swift
//  PawprintWidget
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  The data both widgets share: one entry type and one timeline provider.
//  The app writes a snapshot into the App Group; this reads it and plans
//  when the widget should redraw.
//

import WidgetKit
import SwiftUI

struct PawprintEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot

    var tasks: [UpcomingTask] { snapshot.tasks }
    var overdueCount: Int { snapshot.overdueCount(at: date) }
    var tip: WidgetTip? { snapshot.tip(on: date) }
    var showsDogNames: Bool { snapshot.showsDogNames }

    /// Made-up data for the widget gallery and previews, so it looks real
    /// before the person has added anything.
    static var sample: PawprintEntry {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        return PawprintEntry(
            date: now,
            snapshot: WidgetSnapshot(
                generatedAt: now,
                tasks: [
                    UpcomingTask(title: "Brush coat", dueDate: now.addingTimeInterval(-60 * 60), dogName: "Biscuit"),
                    UpcomingTask(title: "Evening walk", dueDate: now.addingTimeInterval(45 * 60), dogName: "Biscuit"),
                    UpcomingTask(title: "Rabies booster", dueDate: now.addingTimeInterval(26 * 60 * 60), dogName: "Milo", kind: .health),
                    UpcomingTask(title: "Dinner", dueDate: now.addingTimeInterval(3 * 60 * 60), dogName: "Milo")
                ].sorted { $0.dueDate < $1.dueDate },
                tips: [
                    WidgetTip(
                        contentID: "keeping-your-dog-cool",
                        title: "Keeping your dog cool in summer",
                        summary: "Dogs overheat much faster than people. A few habits keep them safe when the temperature climbs.",
                        categoryTitle: "Health",
                        categoryImage: "cross.case.fill",
                        day: startOfDay
                    )
                ],
                dogCount: 2
            )
        )
    }
}

struct PawprintProvider: TimelineProvider {
    private let store: WidgetSnapshotStore = AppGroupWidgetSnapshotStore()

    func placeholder(in context: Context) -> PawprintEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (PawprintEntry) -> Void) {
        let snapshot = store.load()
        if context.isPreview && snapshot.tasks.isEmpty && snapshot.tips.isEmpty {
            completion(.sample)
        } else {
            completion(PawprintEntry(date: Date(), snapshot: snapshot))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PawprintEntry>) -> Void) {
        let snapshot = store.load()
        let now = Date()

        // One entry now, one just after each future due date (so "due" flips to
        // "overdue" on time), one at the start of each planned tip day and one at
        // midnight (so "Tomorrow" becomes a time).
        var dates: [Date] = [now]
        dates += snapshot.tasks
            .map { $0.dueDate.addingTimeInterval(1) }
            .filter { $0 > now }
        dates += snapshot.tips
            .map(\.day)
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
            .map { PawprintEntry(date: $0, snapshot: snapshot) }

        completion(Timeline(entries: Array(entries), policy: .atEnd))
    }
}
