//
//  BuildWidgetSnapshotUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Decides what the widgets get to show.
//
//  Routine tasks: overdue ones plus anything due in the next week.
//  Health follow-ups: overdue ones plus anything due in the next month.
//  A follow-up counts as done once a newer record with the same name exists
//  for the same dog (for example, next year's rabies vaccine), so renewed
//  treatments never nag.
//  Everything is merged soonest first and capped to what fits on a widget.
//  A week of daily Learn tips is added, with the vet care guide on top when
//  a health follow-up is due within a week.
//

import Foundation

@MainActor
struct BuildWidgetSnapshotUseCase {
    static let routineHorizonDays = 7
    static let healthHorizonDays = 30
    static let maxTasks = 8

    var tipOfTheDay = TipOfTheDayUseCase()

    func execute(
        tasks: [UpcomingTask],
        healthItems: [HealthDueItem] = [],
        tips: [LearnTip] = [],
        dogCount: Int = 1,
        now: Date = .now
    ) -> WidgetSnapshot {
        let day: TimeInterval = 24 * 60 * 60
        let routineHorizon = now.addingTimeInterval(TimeInterval(Self.routineHorizonDays) * day)
        let healthHorizon = now.addingTimeInterval(TimeInterval(Self.healthHorizonDays) * day)

        let routines = tasks.filter { $0.dueDate <= routineHorizon }

        let outstanding = Self.outstandingHealthItems(healthItems)
        let health: [UpcomingTask] = outstanding.compactMap { item in
            guard let due = item.nextDueDate, due <= healthHorizon else { return nil }
            return UpcomingTask(title: item.title, dueDate: due, dogName: item.dogName, kind: .health)
        }

        let visible = (routines + health)
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(Self.maxTasks)

        let vetDueThisWeek = outstanding.contains { item in
            guard let due = item.nextDueDate else { return false }
            return due <= now.addingTimeInterval(7 * day)
        }

        return WidgetSnapshot(
            generatedAt: now,
            tasks: Array(visible),
            tips: tipOfTheDay.execute(tips: tips, from: now, preferVetGuide: vetDueThisWeek),
            dogCount: dogCount
        )
    }

    /// Records with a follow-up date that no newer record for the same dog has replaced.
    static func outstandingHealthItems(_ items: [HealthDueItem]) -> [HealthDueItem] {
        func key(_ title: String) -> String {
            title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        return items.filter { item in
            guard item.nextDueDate != nil else { return false }
            let replaced = items.contains { other in
                other.dogID == item.dogID
                    && key(other.title) == key(item.title)
                    && other.recordDate > item.recordDate
            }
            return !replaced
        }
    }
}
