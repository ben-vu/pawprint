//
//  BuildSitterSummaryUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Turns a dog, its care details, routines and health records into the
//  plain-text care sheet a dog sitter receives. Only the parts switched on
//  in SitterShareOptions are included, and a section with nothing in it is
//  left out entirely, so the message never has empty headings.
//
//  Routines are shown as the repeating pattern (one line per routine, with
//  its time of day), not as a long list of dated occurrences, because a
//  sitter needs "what happens each day", not a calendar.
//

import Foundation

@MainActor
struct BuildSitterSummaryUseCase {
    static let maxRoutineLines = 12
    static let maxHealthLines = 8

    func execute(
        dog: Dog,
        routines: [RoutineTask],
        healthRecords: [HealthRecord],
        options: SitterShareOptions = SitterShareOptions(),
        now: Date = .now,
        calendar: Calendar = .current
    ) -> String {
        let details = dog.careDetails.trimmed
        var sections: [String] = [header(for: dog)]

        if options.includeOwnerContact {
            let contact = joined([details.ownerName, details.ownerPhone])
            if let section = block("OWNER", lines: contact.isEmpty ? [] : [contact]) {
                sections.append(section)
            }
        }

        if options.includeVet {
            var lines: [String] = []
            let vet = joined([details.vetName, details.vetPhone])
            if !vet.isEmpty { lines.append(vet) }
            if !details.microchipNumber.isEmpty { lines.append("Microchip: \(details.microchipNumber)") }
            if let section = block("VET AND ID", lines: lines) {
                sections.append(section)
            }
        }

        if options.includeFeeding, let section = block("FEEDING", lines: [details.feedingNotes]) {
            sections.append(section)
        }

        if options.includeMedical, let section = block("MEDICAL", lines: [details.medicalNotes]) {
            sections.append(section)
        }

        if options.includeBehaviour, let section = block("BEHAVIOUR AND HOUSE RULES", lines: [details.behaviourNotes]) {
            sections.append(section)
        }

        if options.includeRoutine,
           let section = block("DAILY ROUTINE", lines: routineLines(for: dog, routines: routines, now: now, calendar: calendar)) {
            sections.append(section)
        }

        if options.includeHealthHistory,
           let section = block("VACCINES AND TREATMENTS", lines: healthLines(for: dog, records: healthRecords)) {
            sections.append(section)
        }

        sections.append("Shared from Pawprint on \(now.formatted(date: .abbreviated, time: .omitted))")
        return sections.joined(separator: "\n\n")
    }

    // MARK: Pieces

    private func header(for dog: Dog) -> String {
        let age = dog.ageYears == 0 ? "Under 1 year" : "\(dog.ageYears) yr\(dog.ageYears == 1 ? "" : "s")"
        let weight = dog.weightKg.formatted(.number.precision(.fractionLength(0...1)).grouping(.never))
        let facts = joined([dog.breed, age, "\(weight) kg"])
        return "\(dog.name): care sheet\n\(facts)"
    }

    private func routineLines(for dog: Dog, routines: [RoutineTask], now: Date, calendar: Calendar) -> [String] {
        let startOfToday = calendar.startOfDay(for: now)
        let open = routines
            .filter { ActiveDogUseCase.shows(taskDogID: $0.dog?.id, activeDogID: dog.id) }
            // A missed repeat already has its next occurrence lined up, so it is skipped, like the Routines tab does.
            .filter { !$0.isCompleted && !$0.hasNextOccurrence }
            // One-off tasks only matter if they are still ahead.
            .filter { $0.recurrence != .once || $0.dueDate >= startOfToday }
            .sorted { minutesIntoDay($0.dueDate, calendar) < minutesIntoDay($1.dueDate, calendar) }

        var seen = Set<String>()
        var lines: [String] = []
        for task in open {
            let key = "\(task.title.lowercased())|\(task.categoryRaw)|\(task.recurrenceRaw)"
            guard seen.insert(key).inserted else { continue }
            let time = task.dueDate.formatted(date: .omitted, time: .shortened)
            let when: String
            if task.recurrence == .once {
                when = "\(task.dueDate.formatted(date: .abbreviated, time: .omitted)), \(time)"
            } else {
                when = "\(time), \(task.repeatSummary)"
            }
            lines.append("• \(task.title): \(when)")
            if lines.count == Self.maxRoutineLines { break }
        }
        return lines
    }

    private func healthLines(for dog: Dog, records: [HealthRecord]) -> [String] {
        // Keep only the newest record for each treatment, so last year's rabies vaccine
        // doesn't sit next to this year's.
        var newest: [String: HealthRecord] = [:]
        for record in records where ActiveDogUseCase.shows(taskDogID: record.dog?.id, activeDogID: dog.id) {
            let key = record.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if let existing = newest[key], existing.date >= record.date { continue }
            newest[key] = record
        }
        return newest.values
            .sorted { $0.date > $1.date }
            .prefix(Self.maxHealthLines)
            .map { record in
                var line = "• \(record.title): \(record.date.formatted(date: .abbreviated, time: .omitted))"
                if let due = record.nextDueDate {
                    line += " (next due \(due.formatted(date: .abbreviated, time: .omitted)))"
                }
                return line
            }
    }

    // MARK: Helpers

    /// A titled block, or nil when every line is blank.
    private func block(_ title: String, lines: [String]) -> String? {
        let filled = lines.filter { !$0.isEmpty }
        guard !filled.isEmpty else { return nil }
        return ([title] + filled).joined(separator: "\n")
    }

    private func joined(_ parts: [String]) -> String {
        parts.filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private func minutesIntoDay(_ date: Date, _ calendar: Calendar) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }
}
