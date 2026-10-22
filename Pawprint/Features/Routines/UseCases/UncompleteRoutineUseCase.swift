//
//  UncompleteRoutineUseCase.swift
//  Routines feature (Sana)
//
//  Unticks a task that was ticked by mistake. For a repeating routine the
//  next task that ticking created is removed again, unless it has already
//  been done itself.
//

import Foundation

struct UncompleteRoutineUseCase {
    let repository: RoutineRepository
    let notifications: NotificationService

    func execute(_ task: RoutineTask) throws {
        guard task.isCompleted else { throw RoutineError.notCompleted }

        if let nextID = task.nextOccurrenceID,
           let next = try repository.fetchAll().first(where: { $0.reminderID == nextID }),
           !next.isCompleted {
            notifications.cancelReminder(for: next)
            try repository.delete(next)
            task.hasNextOccurrence = false
            task.nextOccurrenceID = nil
        }

        task.isCompleted = false
        task.completedAt = nil
        try repository.save(task)
        notifications.scheduleReminder(for: task)
    }
}
