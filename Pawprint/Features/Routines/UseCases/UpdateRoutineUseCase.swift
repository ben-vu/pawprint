//
//  UpdateRoutineUseCase.swift
//  Routines feature (Sana)
//
//  Saves changes to an existing routine and moves its reminder to match.
//

import Foundation

struct UpdateRoutineUseCase {
    let repository: RoutineRepository
    let notifications: NotificationService

    func execute(
        _ task: RoutineTask,
        title: String,
        category: RoutineCategory,
        dueDate: Date,
        recurrence: RoutineRecurrence,
        remindMe: Bool
    ) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RoutineError.emptyTitle }
        guard trimmed.count <= CreateRoutineUseCase.maxTitleLength else { throw RoutineError.titleTooLong }

        task.title = trimmed
        task.category = category
        task.dueDate = dueDate
        task.recurrence = recurrence
        task.remindMe = remindMe
        try repository.save(task)

        notifications.cancelReminder(for: task)
        notifications.scheduleReminder(for: task)   // only schedules if still on, unfinished and in the future
    }
}
