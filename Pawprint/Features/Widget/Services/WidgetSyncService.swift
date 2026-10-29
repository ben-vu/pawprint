//
//  WidgetSyncService.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Keeps the widget in step with the app. It listens for every SwiftData
//  save, so ticking off a task, adding a routine or deleting one updates
//  the widgets without the Routines or Health features knowing they exist.
//  It also makes sure the Learn guides are in the database, because the
//  tip of the day widget needs them even if Learn was never opened.
//
//  And it is where tasks ticked off in the widget reach the database: the
//  widget queues them in the App Group and this applies them when the app
//  launches or comes to the foreground.
//

import Foundation
import SwiftData
import WidgetKit
import os

@MainActor
final class WidgetCenterReloader: WidgetReloading {
    func reloadTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

@MainActor
final class WidgetSyncService {
    private let refreshWidget: RefreshWidgetUseCase
    private let applyCompletions: ApplyWidgetCompletionsUseCase
    private let seedTips: SeedTipsUseCase
    private let logger = Logger(subsystem: "com.nootnoot.pawprint", category: "widget")
    private var observer: NSObjectProtocol?

    init(container: ModelContainer) {
        refreshWidget = RefreshWidgetUseCase(
            data: SwiftDataWidgetDataRepository(context: container.mainContext),
            store: AppGroupWidgetSnapshotStore(),
            reloader: WidgetCenterReloader()
        )
        applyCompletions = ApplyWidgetCompletionsUseCase(
            pending: AppGroupPendingCompletionStore(),
            repository: SwiftDataRoutineRepository(context: container.mainContext),
            notifications: UserNotificationService.shared
        )
        seedTips = SeedTipsUseCase(repository: SwiftDataTipRepository(context: container.mainContext))
    }

    /// Refreshes once now, then again after every save.
    func start() {
        guard observer == nil else { return }
        do {
            try seedTips.execute()
        } catch {
            logger.error("Could not prepare Learn guides: \(error.localizedDescription)")
        }
        applyPendingCompletions()
        refresh()
        observer = NotificationCenter.default.addObserver(
            forName: ModelContext.didSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.refresh()
            }
        }
    }

    /// Ticks off the tasks that were completed from the widget. Screens that
    /// are already showing tasks hear about it through `.widgetCompletionsApplied`.
    func applyPendingCompletions() {
        do {
            if try applyCompletions.execute() > 0 {
                NotificationCenter.default.post(name: .widgetCompletionsApplied, object: nil)
            }
        } catch {
            logger.error("Could not apply widget completions: \(error.localizedDescription)")
        }
    }

    func refresh() {
        do {
            try refreshWidget.execute()
        } catch {
            logger.error("Widget refresh failed: \(error.localizedDescription)")
        }
    }
}
