//
//  PawprintTipWidget.swift
//  PawprintWidget
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  The Care tip widget: one Learn guide a day, chosen by the app. When a
//  vaccination or treatment is due soon, the day's tip is the vet care
//  guide. Tapping it opens that guide in the Learn tab.
//

import WidgetKit
import SwiftUI

struct PawprintTipWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetConfig.tipWidgetKind, provider: PawprintProvider()) { entry in
            TipWidgetView(entry: entry)
                .containerBackground(WidgetPalette.background, for: .widget)
        }
        .configurationDisplayName("Care tip")
        .description("A new beginner dog care guide every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct TipWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: PawprintEntry

    var body: some View {
        if let tip = entry.tip {
            content(for: tip)
                .widgetURL(tip.deepLink.url)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Label("TIP OF THE DAY", systemImage: "book.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(WidgetPalette.accent)
                Text("Open Pawprint to load today's tip.")
                    .font(.footnote)
                    .foregroundStyle(WidgetPalette.textSecondary)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func content(for tip: WidgetTip) -> some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text("TIP OF THE DAY")
                    .font(.caption2)
                    .bold()
                    .widgetAccentable()
                Text(tip.title)
                    .font(.headline)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemMedium:
            VStack(alignment: .leading, spacing: 5) {
                category(tip)
                Text(tip.title)
                    .font(.headline)
                    .foregroundStyle(WidgetPalette.textPrimary)
                    .lineLimit(2)
                Text(tip.summary)
                    .font(.caption)
                    .foregroundStyle(WidgetPalette.textSecondary)
                    .lineLimit(3)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 5) {
                category(tip)
                Text(tip.title)
                    .font(.headline)
                    .foregroundStyle(WidgetPalette.textPrimary)
                    .lineLimit(4)
                Spacer(minLength: 0)
                Text("Tap to read")
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func category(_ tip: WidgetTip) -> some View {
        Label(tip.categoryTitle.uppercased(), systemImage: tip.categoryImage)
            .font(.caption2.weight(.bold))
            .foregroundStyle(WidgetPalette.accent)
    }
}

#Preview(as: .systemSmall) {
    PawprintTipWidget()
} timeline: {
    PawprintEntry.sample
}

#Preview(as: .systemMedium) {
    PawprintTipWidget()
} timeline: {
    PawprintEntry.sample
}

#Preview(as: .accessoryRectangular) {
    PawprintTipWidget()
} timeline: {
    PawprintEntry.sample
}
