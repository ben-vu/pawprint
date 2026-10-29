//
//  PendingCompletionStore.swift
//  PawprintWidgetShared
//
//  A small queue in the App Group for routines ticked off in the widget.
//  The widget never opens the app's database, so a tap only records "this
//  task was done at this time" here. The app picks the queue up the next
//  time it launches or comes to the foreground and does the real work
//  (marks the task done, cancels its reminder, lines up the next repeat).
//

import Foundation

nonisolated struct PendingCompletion: Codable, Hashable, Sendable {
    /// The routine's `reminderID` (see `UpcomingTask.taskID`).
    let taskID: String
    let completedAt: Date
}

nonisolated protocol PendingCompletionStore {
    func pending() -> [PendingCompletion]
    func add(_ completion: PendingCompletion) throws
    /// Removes only the given tasks, so a tap that arrives while the app is
    /// busy applying earlier ones is not lost.
    func remove(taskIDs: Set<String>)
}

nonisolated struct AppGroupPendingCompletionStore: PendingCompletionStore {
    private let appGroupID: String
    private let key = "widget.pendingCompletions.v1"

    init(appGroupID: String = WidgetConfig.appGroupID) {
        self.appGroupID = appGroupID
    }

    func pending() -> [PendingCompletion] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key),
              let list = try? JSONDecoder().decode([PendingCompletion].self, from: data)
        else {
            return []
        }
        return list
    }

    func add(_ completion: PendingCompletion) throws {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil,
              let defaults = UserDefaults(suiteName: appGroupID)
        else {
            throw WidgetSyncError.appGroupUnavailable
        }
        var list = pending()
        guard !list.contains(where: { $0.taskID == completion.taskID }) else { return }   // double tap
        list.append(completion)
        do {
            defaults.set(try JSONEncoder().encode(list), forKey: key)
        } catch {
            throw WidgetSyncError.couldNotWriteSnapshot
        }
    }

    func remove(taskIDs: Set<String>) {
        guard !taskIDs.isEmpty, let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let remaining = pending().filter { !taskIDs.contains($0.taskID) }
        if remaining.isEmpty {
            defaults.removeObject(forKey: key)
        } else if let data = try? JSONEncoder().encode(remaining) {
            defaults.set(data, forKey: key)
        }
    }
}
