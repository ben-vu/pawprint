//
//  RoutineViewModel.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
//
//  State for the Routines tab: tasks grouped into overdue, today and
//  upcoming, plus ticking, unticking and deleting them.
//

import Foundation
import Observation

@Observable
final class RoutineViewModel {
    private(set) var tasks: [RoutineTask] = []
    private(set) var today: Date = .now
    var errorMessage: String?
    var categoryFilter: RoutineCategory? = nil   // nil shows every category

    private let repository: RoutineRepository
    private let notifications: NotificationService
    private let calendar: Calendar
    private let selectedDogID: () -> UUID?

    init(
        repository: RoutineRepository,
        notifications: NotificationService,
        calendar: Calendar = .current,
        selectedDogID: @escaping () -> UUID? = { ActiveDogSelection.storedID }
    ) {
        self.repository = repository
        self.notifications = notifications
        self.calendar = calendar
        self.selectedDogID = selectedDogID
    }

    func load(now: Date = .now) {
        today = now
        do {
            // Missed repeating tasks still need tomorrow's walk to appear.
            let repeater = RepeatRoutineUseCase(repository: repository, notifications: notifications, nextOccurrence: NextOccurrenceUseCase(calendar: calendar))
            for task in try repository.fetchAll() where !task.isCompleted && task.dueDate < startOfToday {
                try repeater.execute(task, today: now)
            }
            // Only show the active dog's routines (routines with no dog show for everyone).
            let activeID = selectedDogID()
            tasks = try repository.fetchAll()
                .filter { ActiveDogUseCase.shows(taskDogID: $0.dog?.id, activeDogID: activeID) }
                .sorted { $0.dueDate < $1.dueDate }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func complete(_ task: RoutineTask) {
        do {
            try CompleteRoutineUseCase(repository: repository, notifications: notifications, nextOccurrence: NextOccurrenceUseCase(calendar: calendar))
                .execute(task, now: .now)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uncomplete(_ task: RoutineTask) {
        do {
            try UncompleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ task: RoutineTask) {
        do {
            try DeleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Sections

    /// Unfinished one-off tasks from before today. Missed repeats are left out
    /// because their next occurrence already shows under Today or Upcoming.
    var overdue: [RoutineTask] {
        shown.filter { !$0.isCompleted && !$0.hasNextOccurrence && $0.dueDate < startOfToday }
    }

    var todays: [RoutineTask] {
        shown.filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
    }

    var upcoming: [RoutineTask] {
        shown.filter { !$0.isCompleted && $0.dueDate >= startOfTomorrow }
    }

    /// True when there are no tasks at all, whatever the filter.
    var isEmpty: Bool {
        let all = tasks
        return !all.contains { !$0.isCompleted && !$0.hasNextOccurrence && $0.dueDate < startOfToday }
            && !all.contains { calendar.isDate($0.dueDate, inSameDayAs: today) }
            && !all.contains { !$0.isCompleted && $0.dueDate >= startOfTomorrow }
    }

    // MARK: Category filter

    /// Categories that have at least one task, in the usual order. The filter
    /// bar only shows when there is more than one.
    var availableCategories: [RoutineCategory] {
        let used = Set(tasks.map(\.category))
        return RoutineCategory.allCases.filter { used.contains($0) }
    }

    private var shown: [RoutineTask] {
        // A filter for a category with no tasks left falls back to showing everything.
        guard let categoryFilter, availableCategories.contains(categoryFilter) else { return tasks }
        return tasks.filter { $0.category == categoryFilter }
    }

    private var startOfToday: Date { calendar.startOfDay(for: today) }
    private var startOfTomorrow: Date { calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday }
}
