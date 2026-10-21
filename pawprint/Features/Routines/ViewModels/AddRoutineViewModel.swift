//
//  AddRoutineViewModel.swift
//  Routines feature (Sana)
//
//  Form state for the Add routine sheet.
//

import Foundation
import Observation

@Observable
final class AddRoutineViewModel {
    var title = ""
    var category: RoutineCategory = .walk
    var dueDate: Date
    var recurrence: RoutineRecurrence = .daily
    var remindMe = false
    var notificationsDenied = false
    var errorMessage: String?

    private let create: CreateRoutineUseCase
    private let notifications: NotificationService
    private let dog: Dog?

    init(repository: RoutineRepository, notifications: NotificationService, dog: Dog?, now: Date = .now) {
        self.create = CreateRoutineUseCase(repository: repository, notifications: notifications)
        self.notifications = notifications
        self.dog = dog
        // Default to the next whole hour, a sensible time for most routines.
        let calendar = Calendar.current
        let hourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        self.dueDate = calendar.date(byAdding: .hour, value: 1, to: hourStart) ?? now
    }

    /// Called when the reminder switch flips. Turning it on asks for permission.
    func reminderToggled() async {
        guard remindMe else { return }
        let allowed = await notifications.requestAuthorization()
        notificationsDenied = !allowed
        if !allowed { remindMe = false }
    }

    func save() -> Bool {
        do {
            _ = try create.execute(
                title: title,
                category: category,
                dueDate: dueDate,
                recurrence: recurrence,
                remindMe: remindMe,
                dog: dog
            )
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
