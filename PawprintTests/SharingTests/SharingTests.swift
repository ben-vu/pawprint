//
//  SharingTests.swift
//  PawprintTests
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Covers the "share with a sitter" feature: saving care details, the rules
//  for what goes into the care sheet, and the view model that drives the
//  share sheet. Runs against mock repositories, never SwiftData.
//

import Foundation
import Testing
@testable import Pawprint

@MainActor
struct SharingTests {

    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func days(_ n: Int) -> Date { now.addingTimeInterval(TimeInterval(n) * 86_400) }

    private func makeDog(name: String = "Bella") -> Dog {
        let dog = Dog(name: name, breed: "Border Collie", ageYears: 3, weightKg: 18.5)
        dog.careDetails = DogCareDetails(
            ownerName: "Sam",
            ownerPhone: "0400 000 000",
            vetName: "Harbourside Vet",
            vetPhone: "02 0000 0000",
            microchipNumber: "900123456789012",
            feedingNotes: "1 cup at 7am and 5pm",
            medicalNotes: "Allergic to chicken",
            behaviourNotes: "Nervous around other dogs"
        )
        return dog
    }

    private func summary(
        _ dog: Dog,
        routines: [RoutineTask] = [],
        health: [HealthRecord] = [],
        options: SitterShareOptions = SitterShareOptions()
    ) -> String {
        BuildSitterSummaryUseCase().execute(dog: dog, routines: routines, healthRecords: health, options: options, now: now)
    }

    // MARK: Care details

    @Test func newDogHasNoCareDetails() {
        let dog = Dog(name: "Max", breed: "Pug", ageYears: 2, weightKg: 8)
        #expect(dog.careDetails.isEmpty)
    }

    @Test func careDetailsRoundTripThroughTheDog() {
        let dog = makeDog()
        #expect(dog.ownerName == "Sam")
        #expect(dog.careDetails.vetPhone == "02 0000 0000")
    }

    @Test func trimmingRemovesSurroundingWhitespace() {
        let details = DogCareDetails(ownerName: "  Sam \n", feedingNotes: "\n 1 cup  ")
        #expect(details.trimmed.ownerName == "Sam")
        #expect(details.trimmed.feedingNotes == "1 cup")
    }

    @Test func updateSavesTrimmedCareDetails() throws {
        let repo = MockDogRepository()
        let dog = try CreateDogUseCase(repository: repo).execute(name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18)

        try UpdateDogUseCase(repository: repo).execute(
            dog, name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18, photoData: nil,
            careDetails: DogCareDetails(ownerName: "  Sam  ", vetName: "Harbourside Vet")
        )

        #expect(dog.ownerName == "Sam")
        #expect(dog.vetName == "Harbourside Vet")
    }

    @Test func updateWithoutCareDetailsLeavesThemAlone() throws {
        let repo = MockDogRepository()
        let dog = makeDog()
        repo.items = [dog]

        try UpdateDogUseCase(repository: repo).execute(dog, name: "Bella", breed: "Collie", ageYears: 4, weightKg: 19, photoData: nil)

        #expect(dog.ownerName == "Sam")
        #expect(dog.ageYears == 4)
    }

    @Test func overlongCareDetailsAreRejectedAndNothingChanges() {
        let repo = MockDogRepository()
        let dog = makeDog()
        repo.items = [dog]
        let tooLong = String(repeating: "a", count: DogCareDetails.maxLength + 1)

        #expect(throws: DogError.detailTooLong) {
            try UpdateDogUseCase(repository: repo).execute(
                dog, name: "Bella", breed: "Collie", ageYears: 3, weightKg: 18, photoData: nil,
                careDetails: DogCareDetails(medicalNotes: tooLong)
            )
        }
        #expect(dog.medicalNotes == "Allergic to chicken")
    }

    // MARK: The care sheet

    @Test func sheetIncludesTheDogAndEveryDetail() {
        let text = summary(makeDog())

        #expect(text.contains("Bella: care sheet"))
        #expect(text.contains("Border Collie"))
        #expect(text.contains("Sam"))
        #expect(text.contains("0400 000 000"))
        #expect(text.contains("Harbourside Vet"))
        #expect(text.contains("Microchip: 900123456789012"))
        #expect(text.contains("1 cup at 7am and 5pm"))
        #expect(text.contains("Allergic to chicken"))
        #expect(text.contains("Nervous around other dogs"))
    }

    @Test func switchedOffSectionsAreLeftOut() {
        var options = SitterShareOptions()
        options.includeOwnerContact = false
        options.includeMedical = false

        let text = summary(makeDog(), options: options)

        #expect(!text.contains("0400 000 000"))
        #expect(!text.contains("Allergic to chicken"))
        #expect(text.contains("Harbourside Vet"))
    }

    @Test func emptySectionsGetNoHeading() {
        let dog = Dog(name: "Max", breed: "Pug", ageYears: 0, weightKg: 8)

        let text = summary(dog)

        #expect(text.contains("Max: care sheet"))
        #expect(text.contains("Under 1 year"))
        #expect(!text.contains("OWNER"))
        #expect(!text.contains("FEEDING"))
        #expect(!text.contains("DAILY ROUTINE"))
    }

    @Test func routineShowsOpenRoutinesForThisDogOnly() {
        let bella = makeDog()
        let milo = Dog(name: "Milo", breed: "Pug", ageYears: 2, weightKg: 8)
        let walk = RoutineTask(title: "Morning walk", dueDate: days(1), dog: bella, category: .walk, recurrence: .daily)
        let miloWalk = RoutineTask(title: "Milo's zoomies", dueDate: days(1), dog: milo, category: .play, recurrence: .daily)
        let done = RoutineTask(title: "Finished chore", dueDate: days(1), isCompleted: true, dog: bella, recurrence: .daily)
        let missed = RoutineTask(title: "Missed dinner", dueDate: days(-1), dog: bella, category: .meal, recurrence: .daily)
        missed.hasNextOccurrence = true

        let text = summary(bella, routines: [walk, miloWalk, done, missed])

        #expect(text.contains("DAILY ROUTINE"))
        #expect(text.contains("Morning walk"))
        #expect(!text.contains("Milo's zoomies"))
        #expect(!text.contains("Finished chore"))
        #expect(!text.contains("Missed dinner"))
    }

    @Test func duplicateRoutinesAppearOnce() {
        let dog = makeDog()
        let first = RoutineTask(title: "Dinner", dueDate: days(1), dog: dog, category: .meal, recurrence: .daily)
        let second = RoutineTask(title: "dinner", dueDate: days(2), dog: dog, category: .meal, recurrence: .daily)

        let text = summary(dog, routines: [first, second])

        #expect(text.components(separatedBy: "• ").count - 1 == 1)
    }

    @Test func pastOneOffTasksAreSkipped() {
        let dog = makeDog()
        let old = RoutineTask(title: "Old vet trip", dueDate: days(-10), dog: dog)
        let upcoming = RoutineTask(title: "Groomer visit", dueDate: days(3), dog: dog)

        let text = summary(dog, routines: [old, upcoming])

        #expect(!text.contains("Old vet trip"))
        #expect(text.contains("Groomer visit"))
    }

    @Test func healthShowsOnlyTheNewestRecordForEachTreatment() {
        let dog = makeDog()
        let oldRabies = HealthRecord(title: "Rabies vaccine", date: days(-400), nextDueDate: days(-35), dog: dog, kind: .vaccination)
        let newRabies = HealthRecord(title: "rabies vaccine", date: days(-30), nextDueDate: days(335), dog: dog, kind: .vaccination)
        let worming = HealthRecord(title: "Worming", date: days(-10), dog: dog, kind: .worming)

        let text = summary(dog, health: [oldRabies, newRabies, worming])

        #expect(text.contains("VACCINES AND TREATMENTS"))
        #expect(text.contains("Worming"))
        #expect(text.contains("next due"))
        #expect(text.components(separatedBy: "• ").count - 1 == 2)
    }

    @Test func healthRecordsOfAnotherDogAreLeftOut() {
        let bella = makeDog()
        let milo = Dog(name: "Milo", breed: "Pug", ageYears: 2, weightKg: 8)
        let miloShot = HealthRecord(title: "Milo's booster", date: days(-5), dog: milo)

        let text = summary(bella, health: [miloShot])

        #expect(!text.contains("Milo's booster"))
        #expect(!text.contains("VACCINES AND TREATMENTS"))
    }

    @Test func healthNotesAreNeverShared() {
        let dog = makeDog()
        let record = HealthRecord(title: "Check-up", date: days(-5), notes: "Private owner note", dog: dog)

        #expect(!summary(dog, health: [record]).contains("Private owner note"))
    }

    // MARK: View model

    @Test func viewModelBuildsTheSheetFromLoadedData() {
        let dog = makeDog()
        let routines = MockRoutineRepositoryForDashboard()
        routines.items = [RoutineTask(title: "Evening walk", dueDate: days(1), dog: dog, category: .walk, recurrence: .daily)]
        let health = MockHealthRepository()
        health.items = [HealthRecord(title: "Rabies vaccine", date: days(-30), dog: dog, kind: .vaccination)]
        let viewModel = ShareDogViewModel(dog: dog, routines: routines, health: health)

        viewModel.load()

        #expect(viewModel.summary.contains("Evening walk"))
        #expect(viewModel.summary.contains("Rabies vaccine"))
        #expect(viewModel.subject == "Bella: care sheet")
        #expect(viewModel.hasCareDetails)
    }

    @Test func viewModelRespectsTheChosenOptions() {
        let dog = makeDog()
        let viewModel = ShareDogViewModel(dog: dog, routines: MockRoutineRepositoryForDashboard(), health: MockHealthRepository())
        viewModel.load()

        viewModel.options.includeOwnerContact = false

        #expect(!viewModel.summary.contains("0400 000 000"))
    }

    @Test func viewModelReportsALoadFailure() {
        let health = MockHealthRepository()
        health.shouldFail = true
        let viewModel = ShareDogViewModel(dog: makeDog(), routines: MockRoutineRepositoryForDashboard(), health: health)

        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    @Test func viewModelNudgesWhenThereAreNoCareDetails() {
        let dog = Dog(name: "Max", breed: "Pug", ageYears: 2, weightKg: 8)
        let viewModel = ShareDogViewModel(dog: dog, routines: MockRoutineRepositoryForDashboard(), health: MockHealthRepository())

        #expect(!viewModel.hasCareDetails)
    }
}
