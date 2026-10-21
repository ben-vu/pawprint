//
//  UpcomingTasksWidgetView.swift
//  pawprintWidget
//
//  Created by Benjamin Vu on 21/10/2026.
//

import WidgetKit
import SwiftUI

struct UpcomingTasksWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: UpcomingTasksEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            inline
        case .accessoryRectangular:
            rectangular
        case .systemMedium:
            medium
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
            Text("NEXT TASK")
                .font(.caption2)
                .bold()
                .widgetAccentable()
            if let next = entry.tasks.first {
                Text(next.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(next.dueLabel(at: entry.date))
                    .font(.caption)
                if let dogName = next.dogName {
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
                header

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
                HStack {
                    header
                    Spacer()
                    if entry.overdueCount > 0 {
                        Text("\(entry.overdueCount) overdue")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WidgetPalette.danger)
                    }
                }

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

    // MARK: Pieces

    private var header: some View {
        Label("PAWPRINT", systemImage: "pawprint.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(WidgetPalette.accent)
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
        return HStack(spacing: 6) {
            Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(isOverdue ? WidgetPalette.danger : WidgetPalette.accent)
            Text(task.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(WidgetPalette.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(task.dueLabel(at: entry.date))
                .font(.caption2)
                .foregroundStyle(isOverdue ? WidgetPalette.danger : WidgetPalette.textSecondary)
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
            Text("No tasks due soon. Open Pawprint to add a routine.")
                .font(.caption)
                .foregroundStyle(WidgetPalette.textSecondary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
