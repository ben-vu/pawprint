//
//  UpcomingTaskRepository.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Read-only view of the routine tasks that are not done yet, converted to
//  the plain UpcomingTask value the widget uses.
//

import Foundation
import SwiftData

@MainActor
protocol UpcomingTaskRepository {
    func fetchIncompleteTasks() throws -> [UpcomingTask]
}

@MainActor
final class SwiftDataUpcomingTaskRepository: UpcomingTaskRepository {
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
            UpcomingTask(title: task.title, dueDate: task.dueDate, dogName: task.dog?.name, category: task.categoryRaw)
        }
    }
}
