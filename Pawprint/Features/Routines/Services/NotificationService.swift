//
//  NotificationService.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
//
//  Local reminders through UserNotifications. Use cases only see the
//  protocol, so tests can record calls instead of touching the system.
//

import Foundation
import UserNotifications

protocol NotificationService {
    /// Asks for permission the first time; afterwards returns the saved answer.
    func requestAuthorization() async -> Bool
    func scheduleReminder(for task: RoutineTask)
    func cancelReminder(for task: RoutineTask)
}

final class UserNotificationService: NSObject, NotificationService, UNUserNotificationCenterDelegate {
    static let shared = UserNotificationService()

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleReminder(for task: RoutineTask) {
        guard task.remindMe, !task.isCompleted, task.dueDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.dog.map { "\($0.name) is counting on you." } ?? "Time for this routine."
        content.sound = .default

        let when = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
        center.add(UNNotificationRequest(identifier: task.reminderID, content: content, trigger: trigger))
    }

    func cancelReminder(for task: RoutineTask) {
        center.removePendingNotificationRequests(withIdentifiers: [task.reminderID])
    }

    /// Show reminders as banners even while the app is open.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
