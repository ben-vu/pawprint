//
//  RoutineTask.swift
//  Routines feature (Sana)
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
    var reminderID: String = UUID().uuidString   // identifies its pending notification

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
    case once, daily, weekly

    var id: String { rawValue }

    var name: String {
        switch self {
        case .once: return "Once"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }

    /// Days between occurrences, or nil for a one-off task.
    var dayInterval: Int? {
        switch self {
        case .once: return nil
        case .daily: return 1
        case .weekly: return 7
        }
    }
}
