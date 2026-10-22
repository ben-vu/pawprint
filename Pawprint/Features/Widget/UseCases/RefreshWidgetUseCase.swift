//
//  RefreshWidgetUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Reads the open tasks, builds a snapshot, saves it to the App Group and
//  asks WidgetKit to redraw. Skips all of that when nothing the widget shows
//  has changed, because WidgetKit limits how often a widget may reload.
//

import Foundation

@MainActor
protocol WidgetReloading {
    func reloadTimelines()
}

@MainActor
struct RefreshWidgetUseCase {
    let tasks: UpcomingTaskRepository
    let store: WidgetSnapshotStore
    let reloader: WidgetReloading
    var buildSnapshot = BuildWidgetSnapshotUseCase()

    func execute(now: Date = .now) throws {
        let upcoming: [UpcomingTask]
        do {
            upcoming = try tasks.fetchIncompleteTasks()
        } catch {
            throw WidgetSyncError.couldNotReadTasks
        }

        let snapshot = buildSnapshot.execute(tasks: upcoming, now: now)
        guard snapshot.tasks != store.load().tasks else { return }

        do {
            try store.save(snapshot)
        } catch let error as WidgetSyncError {
            throw error
        } catch {
            throw WidgetSyncError.couldNotWriteSnapshot
        }
        reloader.reloadTimelines()
    }
}
