//
//  WidgetSyncService.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Keeps the widget in step with the app. It listens for every SwiftData
//  save, so ticking off a task, adding a routine or deleting one updates
//  the widget without the Routines feature having to know the widget exists.
//

import Foundation
import SwiftData
import WidgetKit
import os

@MainActor
final class WidgetCenterReloader: WidgetReloading {
    func reloadTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConfig.widgetKind)
    }
}

@MainActor
final class WidgetSyncService {
    private let refreshWidget: RefreshWidgetUseCase
    private let logger = Logger(subsystem: "com.nootnoot.pawprint", category: "widget")
    private var observer: NSObjectProtocol?

    init(container: ModelContainer) {
        refreshWidget = RefreshWidgetUseCase(
            tasks: SwiftDataUpcomingTaskRepository(context: container.mainContext),
            store: AppGroupWidgetSnapshotStore(),
            reloader: WidgetCenterReloader()
        )
    }

    /// Refreshes once now, then again after every save.
    func start() {
        guard observer == nil else { return }
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

    func refresh() {
        do {
            try refreshWidget.execute()
        } catch {
            logger.error("Widget refresh failed: \(error.localizedDescription)")
        }
    }
}
