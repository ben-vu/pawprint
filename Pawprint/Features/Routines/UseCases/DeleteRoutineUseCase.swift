//
//  DeleteRoutineUseCase.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
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
