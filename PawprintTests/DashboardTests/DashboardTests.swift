//
//  DashboardTests.swift
//  PawprintTests
//
//  Created by Natalie Michael on 21/10/2026.
//
//  All tests run against mock repositories, never SwiftData.
//

import Foundation
import Testing
@testable import Pawprint

@MainActor
final class MockDogRepository: DogRepository {
    var items: [Dog] = []
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchAll() throws -> [Dog] {
        if shouldFail { throw MockFailure() }
        return items
    }

    func save(_ dog: Dog) throws {
        if shouldFail { throw MockFailure() }
        if !items.contains(where: { $0 === dog }) { items.append(dog) }
    }

    func delete(_ dog: Dog) throws {
        if shouldFail { throw MockFailure() }
        items.removeAll { $0 === dog }
    }
}

@MainActor
final class MockRoutineRepositoryForDashboard: RoutineRepository {
    var items: [RoutineTask] = []
    func fetchAll() throws -> [RoutineTask] { items }
    func save(_ task: RoutineTask) throws { items.append(task) }
    func delete(_ task: RoutineTask) throws { items.removeAll { $0 === task } }
}

@MainActor
struct DashboardTests {

    // MARK: Creating a dog

    @Test func validProfileIsSaved() throws {
        let repo = MockDogRepository()
        let dog = try CreateDogUseCase(repository: repo).execute(name: "  Bella ", breed: "Border Collie", ageYears: 3, weightKg: 18.5)

        #expect(dog.name == "Bella")
        #expect(repo.items.count == 1)
    }

    @Test func emptyNameIsRejected() {
        let repo = MockDogRepository()
        #expect(throws: DogError.emptyName) {
            try CreateDogUseCase(repository: repo).execute(name: "   ", breed: "Pug", ageYears: 2, weightKg: 8)
        }
        #expect(repo.items.isEmpty)
    }

    @Test func zeroWeightIsRejected() {
        let repo = MockDogRepository()
        #expect(throws: DogError.invalidWeight) {
            try CreateDogUseCase(repository: repo).execute(name: "Max", breed: "Pug", ageYears: 2, weightKg: 0)
        }
    }

    @Test func unrealisticAgeIsRejected() {
        let repo = MockDogRepository()
        #expect(throws: DogError.invalidAge) {
            try CreateDogUseCase(repository: repo).execute(name: "Max", breed: "Pug", ageYears: 45, weightKg: 8)
        }
    }

    // MARK: Editing and deleting

    @Test func updateChangesTheExistingDog() throws {
        let repo = MockDogRepository()
        let dog = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)

        try UpdateDogUseCase(repository: repo).execute(dog, name: "Bella Rose", breed: "Collie", ageYears: 4, weightKg: 19, photoData: nil)

        #expect(repo.items.count == 1)
        #expect(repo.items.first?.name == "Bella Rose")
        #expect(repo.items.first?.ageYears == 4)
    }

    @Test func deleteRemovesTheDog() throws {
        let repo = MockDogRepository()
        let dog = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)

        try DeleteDogUseCase(repository: repo).execute(dog)

        #expect(repo.items.isEmpty)
    }

    // MARK: Today's progress

    @Test func progressCountsOnlyTodaysTasks() {
        let today = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tasks = [
            RoutineTask(title: "Walk", dueDate: today, isCompleted: true),
            RoutineTask(title: "Breakfast", dueDate: today, isCompleted: false),
            RoutineTask(title: "Old walk", dueDate: yesterday, isCompleted: true)
        ]

        let progress = TodayProgressUseCase().execute(tasks: tasks, on: today)

        #expect(progress == TodayProgress(completed: 1, total: 2))
        #expect(progress.isAllDone == false)
    }

    @Test func progressIsAllDoneWhenEveryTaskIsComplete() {
        let tasks = [
            RoutineTask(title: "Walk", dueDate: .now, isCompleted: true),
            RoutineTask(title: "Dinner", dueDate: .now, isCompleted: true)
        ]

        let progress = TodayProgressUseCase().execute(tasks: tasks)

        #expect(progress.isAllDone)
        #expect(progress.fraction == 1)
    }

    // MARK: View models

    @Test func onboardingSurfacesValidationErrorInsteadOfSaving() {
        let repo = MockDogRepository()
        let vm = OnboardingViewModel(repository: repo)
        vm.name = ""
        vm.weightText = "7.5"

        #expect(vm.saveDog() == false)
        #expect(vm.errorMessage == DogError.emptyName.errorDescription)
        #expect(repo.items.isEmpty)
    }

    @Test func dashboardLoadsDogAndProgress() {
        let dogs = MockDogRepository()
        dogs.items = [Dog(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)]
        let routines = MockRoutineRepositoryForDashboard()
        routines.items = [RoutineTask(title: "Walk", dueDate: .now, isCompleted: true)]

        let vm = DashboardViewModel(dogs: dogs, routines: routines)
        vm.load()

        #expect(vm.dog?.name == "Bella")
        #expect(vm.todaysTasks.count == 1)
        #expect(vm.progress == TodayProgress(completed: 1, total: 1))
        #expect(vm.errorMessage == nil)
    }

    @Test func dashboardReportsRepositoryFailure() {
        let dogs = MockDogRepository()
        dogs.shouldFail = true

        let vm = DashboardViewModel(dogs: dogs, routines: MockRoutineRepositoryForDashboard())
        vm.load()

        #expect(vm.errorMessage != nil)
    }
}
