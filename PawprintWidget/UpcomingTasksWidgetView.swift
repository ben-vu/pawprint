//
//  UpcomingTasksWidgetView.swift
//  PawprintWidget
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Layouts for each size of the Upcoming widget. The same entry drives
//  every size.
//

import WidgetKit
import SwiftUI
import UIKit

struct UpcomingTasksWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: PawprintEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            inline
        case .accessoryRectangular:
            rectangular
        case .systemMedium:
            medium
        case .systemLarge:
            large
        default:
            small
        }
    }

    // MARK: Lock Screen

    @ViewBuilder
    private var inline: some View {
        if let next = entry.tasks.first {
            Text("\(next.title) · \(next.dueLabel(at: entry.date))")
        } else {
            Text("Pawprint: all caught up")
        }
    }

    @ViewBuilder
    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("NEXT UP")
                .font(.caption2)
                .bold()
                .widgetAccentable()
            if let next = entry.tasks.first {
                Text(next.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(next.dueLabel(at: entry.date))
                    .font(.caption)
                if entry.showsDogNames, let dogName = next.dogName {
                    Text(dogName)
                        .font(.caption2)
                }
            } else {
                Text("All caught up")
                    .font(.headline)
                Text("Nothing due soon")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Home Screen

    @ViewBuilder
    private var small: some View {
        if let next = entry.tasks.first {
            let status = next.status(at: entry.date)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    header
                    Spacer(minLength: 0)
                    TaskIcon(task: next, size: 44)
                }

                Text(next.dueLabel(at: entry.date))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(status == .overdue ? WidgetPalette.danger : WidgetPalette.textSecondary)

                Text(next.title)
                    .font(.headline)
                    .foregroundStyle(WidgetPalette.textPrimary)
                    .lineLimit(2)

                if let dogName = next.dogName {
                    Text(dogName)
                        .font(.caption)
                        .foregroundStyle(WidgetPalette.textSecondary)
                }

                Spacer(minLength: 0)

                footer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .widgetURL(next.deepLink.url)
        } else {
            allCaughtUp
        }
    }

    @ViewBuilder
    private var medium: some View {
        if entry.tasks.isEmpty {
            allCaughtUp
        } else {
            VStack(alignment: .leading, spacing: 6) {
                headerWithOverdue

                ForEach(entry.tasks.prefix(3)) { task in
                    row(task)
                }

                Spacer(minLength: 0)

                if entry.tasks.count > 3 {
                    Text("+\(entry.tasks.count - 3) more coming up")
                        .font(.caption2)
                        .foregroundStyle(WidgetPalette.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var large: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerWithOverdue

            if entry.tasks.isEmpty {
                Text("All caught up")
                    .font(.headline)
                    .foregroundStyle(WidgetPalette.textPrimary)
                Text("No tasks or vet visits due soon.")
                    .font(.caption)
                    .foregroundStyle(WidgetPalette.textSecondary)
            } else {
                ForEach(entry.tasks.prefix(5)) { task in
                    row(task)
                }
            }

            Spacer(minLength: 0)

            if let tip = entry.tip {
                Link(destination: tip.deepLink.url) {
                    VStack(alignment: .leading, spacing: 3) {
                        Label("TIP OF THE DAY", systemImage: tip.categoryImage)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(WidgetPalette.accent)
                        Text(tip.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(WidgetPalette.textPrimary)
                            .lineLimit(2)
                        Text(tip.summary)
                            .font(.caption)
                            .foregroundStyle(WidgetPalette.textSecondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Pieces

    private var header: some View {
        Label("PAWPRINT", systemImage: "pawprint.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(WidgetPalette.accent)
    }

    private var headerWithOverdue: some View {
        HStack {
            header
            Spacer()
            if entry.overdueCount > 0 {
                Text("\(entry.overdueCount) overdue")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetPalette.danger)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if entry.overdueCount > 1 {
            Text("\(entry.overdueCount) overdue")
                .font(.caption2)
                .foregroundStyle(WidgetPalette.danger)
        } else if entry.tasks.count > 1 {
            Text("+\(entry.tasks.count - 1) more coming up")
                .font(.caption2)
                .foregroundStyle(WidgetPalette.textSecondary)
        }
    }

    private func row(_ task: UpcomingTask) -> some View {
        let isOverdue = task.status(at: entry.date) == .overdue
        return Link(destination: task.deepLink.url) {
            HStack(spacing: 6) {
                TaskIcon(task: task, size: 26)
                VStack(alignment: .leading, spacing: 0) {
                    Text(task.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WidgetPalette.textPrimary)
                        .lineLimit(1)
                    if entry.showsDogNames, let dogName = task.dogName {
                        Text(dogName)
                            .font(.caption2)
                            .foregroundStyle(WidgetPalette.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 4)
                Text(task.dueLabel(at: entry.date))
                    .font(.caption2)
                    .foregroundStyle(isOverdue ? WidgetPalette.danger : WidgetPalette.textSecondary)
            }
        }
    }

    /// Shown when there is nothing due. It is a good state, so it says so
    /// instead of "No data".
    private var allCaughtUp: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            Text("All caught up")
                .font(.headline)
                .foregroundStyle(WidgetPalette.textPrimary)
            Text("Nothing due soon. Open Pawprint to add a routine or health record.")
                .font(.caption)
                .foregroundStyle(WidgetPalette.textSecondary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The icon for a row. Health follow-ups use the health symbol. Routines use
/// the pug illustration for their category, e.g. "TaskWalk" in the widget's
/// asset catalog, and fall back to a paw print for "other" or when the image
/// hasn't been added yet.
struct TaskIcon: View {
    let task: UpcomingTask
    let size: CGFloat

    private var imageName: String? {
        guard task.kind == .routine, let category = task.category, category != "other" else { return nil }
        let name = "Task" + category.capitalized
        return UIImage(named: name) == nil ? nil : name
    }

    var body: some View {
        Group {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: task.kind == .routine ? "pawprint.fill" : task.kind.systemImage)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundStyle(WidgetPalette.accent)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
