//
//  DashboardTests.swift
//  PawprintTests
//
//  Created by Natalie Michael on 20/10/2026.
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

    // MARK: Mixed breed

    @Test func mixedBreedWithBlankBreedIsSaved() throws {
        let repo = MockDogRepository()
        let dog = try CreateDogUseCase(repository: repo).execute(name: "Max", breed: "", ageYears: 2, weightKg: 8, isMixedBreed: true)

        #expect(dog.isMixedBreed)
        #expect(dog.breedDescription == "Mixed breed")
        #expect(repo.items.count == 1)
    }

    @Test func breedDescriptionCoversEveryCase() {
        #expect(Dog(name: "A", breed: "Pug", ageYears: 1, weightKg: 8).breedDescription == "Pug")
        #expect(Dog(name: "B", breed: "", ageYears: 1, weightKg: 8).breedDescription == "Good dog")
        #expect(Dog(name: "C", breed: "Kelpie", ageYears: 1, weightKg: 8, isMixedBreed: true).breedDescription == "Kelpie mix")
        #expect(Dog(name: "D", breed: "", ageYears: 1, weightKg: 8, isMixedBreed: true).breedDescription == "Mixed breed")
    }

    @Test func updateCanTurnMixedBreedOn() throws {
        let repo = MockDogRepository()
        let dog = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)

        try UpdateDogUseCase(repository: repo).execute(dog, name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18, photoData: nil, isMixedBreed: true)

        #expect(repo.items.first?.isMixedBreed == true)
        #expect(repo.items.first?.breedDescription == "Collie mix")
    }

    // MARK: Breed suggestions

    @Test func typingTheStartOfABreedSuggestsIt() {
        let suggestions = SuggestBreedsUseCase().execute(query: "sta")
        #expect(suggestions == ["Staffy"])
    }

    @Test func suggestionsMatchAnyWordInTheBreedName() {
        let suggestions = SuggestBreedsUseCase().execute(query: "Collie")
        #expect(suggestions == ["Border Collie"])
    }

    @Test func suggestionsAreCappedAndCaseInsensitive() {
        let suggestions = SuggestBreedsUseCase(breeds: ["Alpha", "Alder", "Almond", "Alpine"], limit: 3).execute(query: "AL")
        #expect(suggestions.count == 3)
    }

    @Test func noSuggestionsWhenBlankOrAlreadyExact() {
        let useCase = SuggestBreedsUseCase()
        #expect(useCase.execute(query: "   ").isEmpty)
        #expect(useCase.execute(query: "Kelpie").isEmpty)
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

    // MARK: More than one dog

    @Test func secondDogWithTheSameNameIsRejected() throws {
        let repo = MockDogRepository()
        _ = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)

        #expect(throws: DogError.duplicateName("bella")) {
            try CreateDogUseCase(repository: repo).execute(name: "bella", breed: "Pug", ageYears: 2, weightKg: 8)
        }
        #expect(repo.items.count == 1)
    }

    @Test func aSecondDogWithADifferentNameIsSaved() throws {
        let repo = MockDogRepository()
        _ = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)
        _ = try CreateDogUseCase(repository: repo).execute(name: "Milo", breed: "Pug", ageYears: 2, weightKg: 8)

        #expect(repo.items.map(\.name) == ["Bella", "Milo"])
    }

    @Test func renamingADogToAnotherDogsNameIsRejected() throws {
        let repo = MockDogRepository()
        _ = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)
        let milo = try CreateDogUseCase(repository: repo).execute(name: "Milo", breed: "Pug", ageYears: 2, weightKg: 8)

        #expect(throws: DogError.duplicateName("Bella")) {
            try UpdateDogUseCase(repository: repo).execute(milo, name: "Bella", breed: "Pug", ageYears: 2, weightKg: 8, photoData: nil)
        }
    }

    @Test func activeDogIsTheSelectedOneOrTheFirstWhenNoneIsSelected() {
        let bella = Dog(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)
        let milo = Dog(name: "Milo", breed: "Pug", ageYears: 2, weightKg: 8)
        let useCase = ActiveDogUseCase()

        #expect(useCase.activeDog(in: [bella, milo], selectedID: milo.id) === milo)
        #expect(useCase.activeDog(in: [bella, milo], selectedID: nil) === bella)
        #expect(useCase.activeDog(in: [bella, milo], selectedID: UUID()) === bella)
        #expect(useCase.activeDog(in: [], selectedID: nil) == nil)
    }

    @Test func routinesWithNoDogShowForEveryDog() {
        let dogID = UUID()

        #expect(ActiveDogUseCase.shows(taskDogID: nil, activeDogID: dogID))
        #expect(ActiveDogUseCase.shows(taskDogID: dogID, activeDogID: dogID))
        #expect(ActiveDogUseCase.shows(taskDogID: UUID(), activeDogID: dogID) == false)
    }

    @Test func dashboardOnlyShowsTheSelectedDogsTasks() {
        let bella = Dog(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)
        let milo = Dog(name: "Milo", breed: "Pug", ageYears: 2, weightKg: 8)
        let dogs = MockDogRepository()
        dogs.items = [bella, milo]
        let routines = MockRoutineRepositoryForDashboard()
        routines.items = [
            RoutineTask(title: "Bella walk", dueDate: .now, dog: bella),
            RoutineTask(title: "Milo dinner", dueDate: .now, dog: milo),
            RoutineTask(title: "Shared task", dueDate: .now)
        ]

        let vm = DashboardViewModel(dogs: dogs, routines: routines)
        vm.load(selectedDogID: milo.id)

        #expect(vm.dog === milo)
        #expect(vm.dogCount == 2)
        #expect(Set(vm.todaysTasks.map(\.title)) == ["Milo dinner", "Shared task"])
        #expect(vm.progress.total == 2)
    }

    // MARK: Add another dog

    @Test func addDogSavesTheMixedBreedFlag() throws {
        let repo = MockDogRepository()
        let vm = AddDogViewModel(repository: repo)
        vm.name = "Milo"
        vm.breed = "Kelpie"
        vm.isMixedBreed = true
        vm.weightText = "14"

        let dog = try #require(vm.save())

        #expect(dog.isMixedBreed)
        #expect(dog.breedDescription == "Kelpie mix")
        #expect(repo.items.count == 1)
    }

    @Test func addDogOffersBreedSuggestionsLikeOnboarding() {
        let vm = AddDogViewModel(repository: MockDogRepository())
        vm.breed = "kel"

        #expect(vm.breedSuggestions.contains("Kelpie"))
    }
}
