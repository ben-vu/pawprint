//
//  ApplyWidgetCompletionsUseCase.swift
//  Pawprint
//
//  Takes the tasks that were ticked off in the widget and completes them
//  properly in the app: marks them done, cancels their reminders and, for a
//  repeating routine, lines up the next one. It reuses
//  CompleteRoutineUseCase, so ticking in the widget behaves exactly like
//  ticking in the app.
//

import Foundation

extension Notification.Name {
    /// Posted after tasks ticked off in the widget have been saved, so the
    /// Home and Routines screens can reload.
    static let widgetCompletionsApplied = Notification.Name("pawprint.widgetCompletionsApplied")
}

@MainActor
struct ApplyWidgetCompletionsUseCase {
    let pending: PendingCompletionStore
    let repository: RoutineRepository
    let notifications: NotificationService
    var nextOccurrence = NextOccurrenceUseCase()

    /// Returns how many tasks were newly ticked off. Requests for tasks that
    /// no longer exist, or are already done (ticked in the app first), are
    /// dropped. If something fails the unprocessed ones stay queued for next time.
    @discardableResult
    func execute() throws -> Int {
        let requests = pending.pending()
        guard !requests.isEmpty else { return 0 }

        let tasks = try repository.fetchAll()
        let complete = CompleteRoutineUseCase(
            repository: repository,
            notifications: notifications,
            nextOccurrence: nextOccurrence
        )

        var handled = Set<String>()
        var applied = 0
        defer { pending.remove(taskIDs: handled) }

        for request in requests {
            if let task = tasks.first(where: { $0.reminderID == request.taskID }), !task.isCompleted {
                try complete.execute(task, now: request.completedAt)
                applied += 1
            }
            handled.insert(request.taskID)
        }
        return applied
    }
}
