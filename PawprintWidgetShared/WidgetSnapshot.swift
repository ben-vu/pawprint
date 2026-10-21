//
//  WidgetSnapshot.swift
//  pawprintWidgetShared
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Everything the widget needs to draw itself, written by the app and read
//  by the widget. Tasks are sorted by due date, so overdue tasks come first.
//

import Foundation

nonisolated struct WidgetSnapshot: Codable, Equatable, Sendable {
    var generatedAt: Date
    var tasks: [UpcomingTask]

    static let empty = WidgetSnapshot(generatedAt: .distantPast, tasks: [])

    func overdueCount(at now: Date) -> Int {
        tasks.filter { $0.dueDate < now }.count
    }
}
