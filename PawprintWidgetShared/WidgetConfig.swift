//
//  WidgetConfig.swift
//  PawprintWidgetShared
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  The values the two targets must agree on. The App Group ID has to match
//  the entitlements files of both targets exactly, otherwise each one gets
//  its own private storage and the widget never sees the app's data.
//

import Foundation

nonisolated enum WidgetConfig {
    static let appGroupID = "group.com.nootnoot.pawprint"
    static let widgetKind = "PawprintUpcomingTasksWidget"
}
