//
//  RepeatRoutineUseCase.swift
//  Routines feature (Sana)
//
//  Creates the next task in a repeating routine. Runs when a task is
//  completed, and when the list loads for tasks that were missed.
//

import Foundation

struct RepeatRoutineUseCase {
    let repository: RoutineRepository
    let notifications: NotificationService
    var nextOccurrence = NextOccurrenceUseCase()

    /// Returns the new task, or nil if the task doesn't repeat or already has a next one.
    @discardableResult
    func execute(_ task: RoutineTask, today: Date = .now) throws -> RoutineTask? {
        guard !task.hasNextOccurrence,
              let nextDate = nextOccurrence.execute(
                after: task.dueDate,
                recurrence: task.recurrence,
                weekdays: task.repeatWeekdays,
                everyWeeks: task.repeatEveryWeeks,
                today: today
              )
        else { return nil }

        let next = RoutineTask(
            title: task.title,
            dueDate: nextDate,
            dog: task.dog,
            category: task.category,
            recurrence: task.recurrence,
            remindMe: task.remindMe
        )
        next.repeatWeekdays = task.repeatWeekdays
        next.repeatEveryWeeks = task.repeatEveryWeeks
        try repository.save(next)
        task.hasNextOccurrence = true
        task.nextOccurrenceID = next.reminderID
        try repository.save(task)
        notifications.scheduleReminder(for: next)
        return next
    }
}
