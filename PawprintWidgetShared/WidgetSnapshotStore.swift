//
//  WidgetSnapshotStore.swift
//  pawprintWidgetShared
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Reads and writes the snapshot in the App Group container, the one piece
//  of storage the app and the widget can both open.
//

import Foundation

nonisolated enum WidgetSyncError: Error, LocalizedError, Equatable {
    case appGroupUnavailable
    case couldNotReadTasks
    case couldNotWriteSnapshot

    var errorDescription: String? {
        switch self {
        case .appGroupUnavailable:
            return "The App Group is not set up, so the widget can't share data with the app."
        case .couldNotReadTasks:
            return "The app couldn't read the tasks to show in the widget."
        case .couldNotWriteSnapshot:
            return "The app couldn't save the widget's data."
        }
    }
}

nonisolated protocol WidgetSnapshotStore {
    func load() -> WidgetSnapshot
    func save(_ snapshot: WidgetSnapshot) throws
}

nonisolated struct AppGroupWidgetSnapshotStore: WidgetSnapshotStore {
    private let appGroupID: String
    private let key = "widget.upcomingTasks.v1"

    init(appGroupID: String = WidgetConfig.appGroupID) {
        self.appGroupID = appGroupID
    }

    /// An empty snapshot is returned if nothing has been saved yet or the data can't be read,
    /// so the widget always has something sensible to draw.
    func load() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }

    func save(_ snapshot: WidgetSnapshot) throws {
        // A missing container means the App Group is not in the entitlements.
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil,
              let defaults = UserDefaults(suiteName: appGroupID)
        else {
            throw WidgetSyncError.appGroupUnavailable
        }
        do {
            defaults.set(try JSONEncoder().encode(snapshot), forKey: key)
        } catch {
            throw WidgetSyncError.couldNotWriteSnapshot
        }
    }
}
