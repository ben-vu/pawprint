//
//  CreateRoutineUseCase.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
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
        remindMe: Bool,
        dog: Dog? = nil
    ) throws -> RoutineTask {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RoutineError.emptyTitle }
        guard trimmed.count <= Self.maxTitleLength else { throw RoutineError.titleTooLong }

        let task = RoutineTask(
            title: trimmed,
            dueDate: dueDate,
            dog: dog,
            category: category,
            recurrence: recurrence,
            remindMe: remindMe
        )
        try repository.save(task)
        notifications.scheduleReminder(for: task)
        return task
    }
}
