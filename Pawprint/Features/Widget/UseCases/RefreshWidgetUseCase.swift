//
//  RefreshWidgetUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Reads routines, health records, Learn guides and dogs, builds a
//  snapshot, saves it to the App Group and asks WidgetKit to redraw. Skips
//  the save and reload when nothing the widgets show has changed, because
//  WidgetKit limits how often a widget may reload.
//

import Foundation

@MainActor
protocol WidgetReloading {
    func reloadTimelines()
}

@MainActor
struct RefreshWidgetUseCase {
    let data: WidgetDataRepository
    let store: WidgetSnapshotStore
    let reloader: WidgetReloading
    var buildSnapshot = BuildWidgetSnapshotUseCase()

    func execute(now: Date = .now) throws {
        let snapshot: WidgetSnapshot
        do {
            snapshot = buildSnapshot.execute(
                tasks: try data.fetchIncompleteTasks(),
                healthItems: try data.fetchHealthRecords(),
                tips: try data.fetchTips(),
                dogCount: try data.fetchDogCount(),
                now: now
            )
        } catch {
            throw WidgetSyncError.couldNotReadTasks
        }

        guard !snapshot.hasSameContent(as: store.load()) else { return }

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
