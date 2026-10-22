//
//  PawprintWidget.swift
//  PawprintWidget
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  The Upcoming widget.
//
//  The scenario it is built for: a new dog owner glances at their phone and
//  wants to know "what do I need to do for the dog next?" without opening
//  the app. It shows routine tasks and health follow-ups (vaccinations,
//  flea and worming treatments, check-ups) together, flags overdue ones,
//  and, on the large size, adds today's Learn tip. Tapping a row opens the
//  matching tab of the app.
//
//  Data comes from a snapshot the app writes into the App Group (see
//  WidgetSyncService in the app target). The widget never opens the app's
//  database.
//

import WidgetKit
import SwiftUI

struct PawprintWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetConfig.widgetKind, provider: PawprintProvider()) { entry in
            UpcomingTasksWidgetView(entry: entry)
                .containerBackground(WidgetPalette.background, for: .widget)
        }
        .configurationDisplayName("Upcoming")
        .description("The next walks, meals, treatments and vet visits for your dogs, plus a care tip.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
    }
}

#Preview(as: .systemSmall) {
    PawprintWidget()
} timeline: {
    PawprintEntry.sample
    PawprintEntry(date: Date(), snapshot: .empty)
}

#Preview(as: .systemMedium) {
    PawprintWidget()
} timeline: {
    PawprintEntry.sample
}

#Preview(as: .systemLarge) {
    PawprintWidget()
} timeline: {
    PawprintEntry.sample
}

#Preview(as: .accessoryRectangular) {
    PawprintWidget()
} timeline: {
    PawprintEntry.sample
}

#Preview(as: .accessoryInline) {
    PawprintWidget()
} timeline: {
    PawprintEntry.sample
}
