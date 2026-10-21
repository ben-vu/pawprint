//
//  BuildWidgetSnapshotUseCase.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Decides what the widget gets to show: overdue tasks plus anything due in
//  the next week, soonest first, capped to what fits on a widget.
//

import Foundation

@MainActor
struct BuildWidgetSnapshotUseCase {
    static let horizonDays = 7
    static let maxTasks = 8

    func execute(tasks: [UpcomingTask], now: Date = .now) -> WidgetSnapshot {
        let horizon = now.addingTimeInterval(TimeInterval(Self.horizonDays * 24 * 60 * 60))
        let visible = tasks
            .filter { $0.dueDate <= horizon }
            .sorted { $0.dueDate < $1.dueDate }
        return WidgetSnapshot(generatedAt: now, tasks: Array(visible.prefix(Self.maxTasks)))
    }
}
