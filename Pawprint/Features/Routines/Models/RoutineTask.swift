//
//  RoutineTask.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
//
//  One occurrence of a routine. A repeating routine is a chain of tasks:
//  when one is done (or missed), the next one is created with the same
//  details and a later due date. That keeps "today" a simple date filter,
//  which the Dashboard relies on.
//

import Foundation
import SwiftData

@Model
final class RoutineTask {
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var dog: Dog?

    // New fields have defaults so existing stores migrate without help.
    var categoryRaw: String = RoutineCategory.other.rawValue
    var recurrenceRaw: String = RoutineRecurrence.once.rawValue
    var remindMe: Bool = false
    var completedAt: Date?
    var hasNextOccurrence: Bool = false          // stops a repeating task spawning its next one twice
    var nextOccurrenceID: String?                // reminderID of that next task, so unticking can remove it
    var reminderID: String = UUID().uuidString   // identifies its pending notification
    var repeatWeekdaysRaw: String = ""           // Calendar weekdays (1 = Sunday) for .weekdays, e.g. "2,4,6"
    var repeatEveryWeeks: Int = 2                // gap in weeks for .everyFewWeeks

    init(
        title: String,
        dueDate: Date,
        isCompleted: Bool = false,
        dog: Dog? = nil,
        category: RoutineCategory = .other,
        recurrence: RoutineRecurrence = .once,
        remindMe: Bool = false
    ) {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.dog = dog
        self.categoryRaw = category.rawValue
        self.recurrenceRaw = recurrence.rawValue
        self.remindMe = remindMe
    }

    var category: RoutineCategory {
        get { RoutineCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var recurrence: RoutineRecurrence {
        get { RoutineRecurrence(rawValue: recurrenceRaw) ?? .once }
        set { recurrenceRaw = newValue.rawValue }
    }

    var repeatWeekdays: Set<Int> {
        get { Set(repeatWeekdaysRaw.split(separator: ",").compactMap { Int($0) }) }
        set { repeatWeekdaysRaw = newValue.sorted().map(String.init).joined(separator: ",") }
    }

    /// Short description for the list, e.g. "Daily", "Mon, Wed, Fri" or "Every 4 weeks".
    var repeatSummary: String {
        switch recurrence {
        case .weekdays:
            let symbols = Calendar.current.shortWeekdaySymbols
            return RoutineRecurrence.weekdayOrder
                .filter { repeatWeekdays.contains($0) }
                .map { symbols[$0 - 1] }
                .joined(separator: ", ")
        case .everyFewWeeks:
            return "Every \(repeatEveryWeeks) weeks"
        default:
            return recurrence.name
        }
    }
}

nonisolated enum RoutineCategory: String, CaseIterable, Identifiable {
    case walk, meal, medication, grooming, teeth, play, other

    var id: String { rawValue }

    var name: String {
        switch self {
        case .walk: return "Walk"
        case .meal: return "Meal"
        case .medication: return "Medication"
        case .grooming: return "Grooming"
        case .teeth: return "Teeth"
        case .play: return "Play"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .walk: return "figure.walk"
        case .meal: return "fork.knife"
        case .medication: return "pills.fill"
        case .grooming: return "scissors"
        case .teeth: return "mouth.fill"
        case .play: return "tennisball.fill"
        case .other: return "pawprint.fill"
        }
    }

    /// Example title shown in the empty text field.
    var placeholder: String {
        switch self {
        case .walk: return "Morning walk"
        case .meal: return "Breakfast"
        case .medication: return "Flea tablet"
        case .grooming: return "Brush coat"
        case .teeth: return "Brush teeth"
        case .play: return "Fetch in the park"
        case .other: return "Vet check-up"
        }
    }
}

nonisolated enum RoutineRecurrence: String, CaseIterable, Identifiable {
    case once, daily, twiceDaily, weekly, weekdays, everyFewWeeks

    var id: String { rawValue }

    var name: String {
        switch self {
        case .once: return "Once"
        case .daily: return "Daily"
        case .twiceDaily: return "Twice a day"
        case .weekly: return "Weekly"
        case .weekdays: return "Certain days"
        case .everyFewWeeks: return "Every few weeks"
        }
    }

    /// Calendar weekday numbers starting from Monday, for showing days in order.
    static let weekdayOrder = [2, 3, 4, 5, 6, 7, 1]

    /// Allowed gap for .everyFewWeeks.
    static let everyWeeksRange = 2...12
}
