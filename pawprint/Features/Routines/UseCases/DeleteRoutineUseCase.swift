//
//  DeleteRoutineUseCase.swift
//  Routines feature (Sana)
//

import Foundation

struct DeleteRoutineUseCase {
    let repository: RoutineRepository
    let notifications: NotificationService

    func execute(_ task: RoutineTask) throws {
        notifications.cancelReminder(for: task)
        try repository.delete(task)
    }
}
