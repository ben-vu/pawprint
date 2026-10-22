//
//  CreateRoutineUseCase.swift
//  Routines feature (Sana)
//

import Foundation

struct CreateRoutineUseCase {
    let repository: RoutineRepository
    let notifications: NotificationService

    static let maxTitleLength = 60

    func execute(
        title: String,
        category: RoutineCategory,
        dueDate: Date,
        recurrence: RoutineRecurrence,
        weekdays: Set<Int> = [],
        everyWeeks: Int = 2,
        remindMe: Bool,
        dog: Dog? = nil
    ) throws -> RoutineTask {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RoutineError.emptyTitle }
        guard trimmed.count <= Self.maxTitleLength else { throw RoutineError.titleTooLong }
        try Self.validateRepeat(recurrence: recurrence, weekdays: weekdays, everyWeeks: everyWeeks)

        let task = RoutineTask(
            title: trimmed,
            dueDate: dueDate,
            dog: dog,
            category: category,
            recurrence: recurrence,
            remindMe: remindMe
        )
        task.repeatWeekdays = weekdays
        task.repeatEveryWeeks = everyWeeks
        try repository.save(task)
        notifications.scheduleReminder(for: task)
        return task
    }

    /// Checks the extra settings that some repeat rules need.
    static func validateRepeat(recurrence: RoutineRecurrence, weekdays: Set<Int>, everyWeeks: Int) throws {
        if recurrence == .weekdays && weekdays.isEmpty { throw RoutineError.noWeekdaysChosen }
        if recurrence == .everyFewWeeks && !RoutineRecurrence.everyWeeksRange.contains(everyWeeks) {
            throw RoutineError.invalidWeekGap
        }
    }
}
