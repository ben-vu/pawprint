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
        tasks.filter { !$0.isCompleted && !$0.hasNextOccurrence && $0.dueDate < startOfToday }
    }

    var todays: [RoutineTask] {
        tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
    }

    var upcoming: [RoutineTask] {
        tasks.filter { !$0.isCompleted && $0.dueDate >= startOfTomorrow }
    }

    var isEmpty: Bool { overdue.isEmpty && todays.isEmpty && upcoming.isEmpty }

    private var startOfToday: Date { calendar.startOfDay(for: today) }
    private var startOfTomorrow: Date { calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday }
}
