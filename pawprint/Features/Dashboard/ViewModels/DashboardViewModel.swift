//
//  DashboardViewModel.swift
//  Dashboard feature (Natalie)
//
//  State for the Home screen: the dog, today's tasks and progress.
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private(set) var dog: Dog?
    private(set) var todaysTasks: [RoutineTask] = []
    private(set) var progress = TodayProgress(completed: 0, total: 0)
    var errorMessage: String?

    private let dogs: DogRepository
    private let routines: RoutineRepository
    private let progressUseCase: TodayProgressUseCase

    init(dogs: DogRepository, routines: RoutineRepository, progressUseCase: TodayProgressUseCase = TodayProgressUseCase()) {
        self.dogs = dogs
        self.routines = routines
        self.progressUseCase = progressUseCase
    }

    func load(on day: Date = .now) {
        do {
            dog = try dogs.fetchAll().first
            let all = try routines.fetchAll()
            todaysTasks = all
                .filter { Calendar.current.isDate($0.dueDate, inSameDayAs: day) }
                .sorted { $0.dueDate < $1.dueDate }
            progress = progressUseCase.execute(tasks: all, on: day)
            errorMessage = nil
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
