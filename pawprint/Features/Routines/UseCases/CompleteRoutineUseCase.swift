//
//  CompleteRoutineUseCase.swift
//  Routines feature (Sana)
//
//  Ticks a task off, clears its reminder and, for a repeating routine,
//  lines up the next one.
//

import Foundation

nonisolated enum RoutineError: DomainError {
    case alreadyCompleted
    case notCompleted
    case emptyTitle
    case titleTooLong

    var errorDescription: String? {
        switch self {
        case .alreadyCompleted: return "This task is already done."
        case .notCompleted: return "This task isn't done yet."
        case .emptyTitle: return "Please give the routine a name."
        case .titleTooLong: return "Keep the name under 60 characters."
        }
    }
}

struct CompleteRoutineUseCase {
    let repository: RoutineRepository
    let notifications: NotificationService
    var nextOccurrence = NextOccurrenceUseCase()

    /// Returns the next task if the routine repeats.
    @discardableResult
    func execute(_ task: RoutineTask, now: Date = .now) throws -> RoutineTask? {
        guard !task.isCompleted else { throw RoutineError.alreadyCompleted }
        task.isCompleted = true
        task.completedAt = now
        try repository.save(task)
        notifications.cancelReminder(for: task)

        let repeater = RepeatRoutineUseCase(repository: repository, notifications: notifications, nextOccurrence: nextOccurrence)
        return try repeater.execute(task, today: now)
    }
}
