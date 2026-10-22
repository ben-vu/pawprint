//
//  WidgetDataRepository.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Read-only access to everything the widgets show: open routine tasks,
//  health records, Learn guides and the number of dogs. Converted to plain
//  values so the widget code never sees SwiftData.
//

import Foundation
import SwiftData

@MainActor
protocol WidgetDataRepository {
    func fetchIncompleteTasks() throws -> [UpcomingTask]
    func fetchHealthRecords() throws -> [HealthDueItem]
    func fetchTips() throws -> [LearnTip]
    func fetchDogCount() throws -> Int
}

@MainActor
final class SwiftDataWidgetDataRepository: WidgetDataRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchIncompleteTasks() throws -> [UpcomingTask] {
        // A missed repeat already has its next occurrence lined up, so it is
        // skipped here just like the Routines tab skips it.
        let descriptor = FetchDescriptor<RoutineTask>(
            predicate: #Predicate<RoutineTask> { !$0.isCompleted && !$0.hasNextOccurrence },
            sortBy: [SortDescriptor(\.dueDate)]
        )
        return try context.fetch(descriptor).map { task in
            UpcomingTask(
                title: task.title,
                dueDate: task.dueDate,
                dogName: task.dog?.name,
                category: task.categoryRaw,
                kind: .routine
            )
        }
    }

    func fetchHealthRecords() throws -> [HealthDueItem] {
        try context.fetch(FetchDescriptor<HealthRecord>()).map { record in
            HealthDueItem(
                title: record.title,
                recordDate: record.date,
                nextDueDate: record.nextDueDate,
                dogName: record.dog?.name,
                dogID: record.dog?.id
            )
        }
    }

    func fetchTips() throws -> [LearnTip] {
        try context.fetch(FetchDescriptor<LearnTip>(sortBy: [SortDescriptor(\.sortOrder)]))
    }

    func fetchDogCount() throws -> Int {
        try context.fetch(FetchDescriptor<Dog>()).count
    }
}
