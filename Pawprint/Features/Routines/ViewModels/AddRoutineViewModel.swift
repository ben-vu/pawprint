//
//  AddRoutineViewModel.swift
//  Routines feature (Sana)
//
//  Form state for the routine sheet. Creates a new routine, or edits an
//  existing one when given a task.
//

import Foundation
import Observation

@Observable
final class AddRoutineViewModel {
    var title = ""
    var category: RoutineCategory = .walk
    var dueDate: Date
    var recurrence: RoutineRecurrence = .daily
    var weekdays: Set<Int> = []
    var everyWeeks = 2
    var remindMe = false
    var notificationsDenied = false
    var errorMessage: String?

    let editing: RoutineTask?
    var isEditing: Bool { editing != nil }

    private let repository: RoutineRepository
    private let notifications: NotificationService
    private let dog: Dog?

    init(repository: RoutineRepository, notifications: NotificationService, dog: Dog?, editing: RoutineTask? = nil, now: Date = .now) {
        self.repository = repository
        self.notifications = notifications
        self.dog = dog
        self.editing = editing

        if let task = editing {
            title = task.title
            category = task.category
            dueDate = task.dueDate
            recurrence = task.recurrence
            weekdays = task.repeatWeekdays
            everyWeeks = task.repeatEveryWeeks
            remindMe = task.remindMe
        } else {
            // Default to the next whole hour, a sensible time for most routines.
            let calendar = Calendar.current
            let hourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now
            dueDate = calendar.date(byAdding: .hour, value: 1, to: hourStart) ?? now
        }
        // Start "Certain days" on the day it's due, so the first pick isn't empty.
        if weekdays.isEmpty {
            weekdays = [Calendar.current.component(.weekday, from: dueDate)]
        }
    }

    /// Looks up which dog new routines belong to. There is only one dog for
    /// now; this is the place to use the selected dog once there are several.
    convenience init(repository: RoutineRepository, notifications: NotificationService, dogs: DogRepository, editing: RoutineTask? = nil) {
        let dog = try? dogs.fetchAll().first
        self.init(repository: repository, notifications: notifications, dog: dog, editing: editing)
    }

    /// Called when the reminder switch flips. Turning it on asks for permission.
    func reminderToggled() async {
        guard remindMe else { return }
        let allowed = await notifications.requestAuthorization()
        notificationsDenied = !allowed
        if !allowed { remindMe = false }
    }

    func toggleWeekday(_ weekday: Int) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        } else {
            weekdays.insert(weekday)
        }
    }

    func save() -> Bool {
        do {
            if let task = editing {
                try UpdateRoutineUseCase(repository: repository, notifications: notifications)
                    .execute(task, title: title, category: category, dueDate: dueDate, recurrence: recurrence, weekdays: weekdays, everyWeeks: everyWeeks, remindMe: remindMe)
            } else {
                _ = try CreateRoutineUseCase(repository: repository, notifications: notifications)
                    .execute(title: title, category: category, dueDate: dueDate, recurrence: recurrence, weekdays: weekdays, everyWeeks: everyWeeks, remindMe: remindMe, dog: dog)
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete() -> Bool {
        guard let task = editing else { return false }
        do {
            try DeleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
