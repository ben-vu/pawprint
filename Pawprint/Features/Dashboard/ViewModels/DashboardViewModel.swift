//
//  DashboardViewModel.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  State for the Home screen: the dog, today's tasks and progress, plus
//  ticking those tasks off (or unticking them).
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private(set) var dog: Dog?
    private(set) var dogCount = 0
    private(set) var todaysTasks: [RoutineTask] = []
    private(set) var progress = TodayProgress(completed: 0, total: 0)
    var errorMessage: String?

    private let dogs: DogRepository
    private let routines: RoutineRepository
    private let notifications: NotificationService
    private let progressUseCase: TodayProgressUseCase

    init(
        dogs: DogRepository,
        routines: RoutineRepository,
        notifications: NotificationService,
        progressUseCase: TodayProgressUseCase = TodayProgressUseCase()
    ) {
        self.dogs = dogs
        self.routines = routines
        self.notifications = notifications
        self.progressUseCase = progressUseCase
    }

    /// Loads the active dog and only that dog's routines (routines with no dog show for everyone).
    func load(on day: Date = .now, selectedDogID: UUID? = ActiveDogSelection.storedID) {
        do {
            let allDogs = try dogs.fetchAll()
            dogCount = allDogs.count
            dog = ActiveDogUseCase().activeDog(in: allDogs, selectedID: selectedDogID)
            let all = try routines.fetchAll().filter {
                ActiveDogUseCase.shows(taskDogID: $0.dog?.id, activeDogID: dog?.id)
            }
            todaysTasks = all
                .filter { Calendar.current.isDate($0.dueDate, inSameDayAs: day) }
                .sorted { $0.dueDate < $1.dueDate }
            progress = progressUseCase.execute(tasks: all, on: day)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Ticks a task off. A repeating routine gets its next occurrence, just
    /// like ticking it in the Routines tab.
    func complete(_ task: RoutineTask) {
        do {
            try CompleteRoutineUseCase(repository: routines, notifications: notifications).execute(task)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uncomplete(_ task: RoutineTask) {
        do {
            try UncompleteRoutineUseCase(repository: routines, notifications: notifications).execute(task)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}
