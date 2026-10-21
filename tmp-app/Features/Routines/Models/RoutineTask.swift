//
//  RoutineTask.swift
//  Routines feature (Sana)
//
//  Starter model. Add recurrence, reminders and whatever else you need.
//

import Foundation
import SwiftData

@Model
final class RoutineTask {
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var dog: Dog?

    init(title: String, dueDate: Date, isCompleted: Bool = false, dog: Dog? = nil) {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.dog = dog
    }
}
