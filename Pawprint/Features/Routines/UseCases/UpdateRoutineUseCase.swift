//
//  UpdateRoutineUseCase.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
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
        weekdays: Set<Int> = [],
        everyWeeks: Int = 2,
        remindMe: Bool
    ) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RoutineError.emptyTitle }
        guard trimmed.count <= CreateRoutineUseCase.maxTitleLength else { throw RoutineError.titleTooLong }
        try CreateRoutineUseCase.validateRepeat(recurrence: recurrence, weekdays: weekdays, everyWeeks: everyWeeks)

        task.title = trimmed
        task.category = category
        task.dueDate = dueDate
        task.recurrence = recurrence
        task.repeatWeekdays = weekdays
        task.repeatEveryWeeks = everyWeeks
        task.remindMe = remindMe
        try repository.save(task)

        notifications.cancelReminder(for: task)
        notifications.scheduleReminder(for: task)   // only schedules if still on, unfinished and in the future
    }
}
