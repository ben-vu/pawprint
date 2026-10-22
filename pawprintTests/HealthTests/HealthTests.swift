//
//  HealthTests.swift
//  PawprintTests
//
//  Created by Natalie Michael on 20/10/2026.
//
//  Pattern: a mock repository that stores items in an array, then tests
//  that drive the ViewModel or use case through the protocol only.
//

import Foundation
import Testing
import SwiftData
@testable import Pawprint

@MainActor
class MockHealthRepository: HealthRepository {
    var items: [HealthRecord] = []
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchRecords(for dog: Dog) throws -> [HealthRecord] {
        if shouldFail { throw MockFailure() }
        return items.filter { $0.dog?.persistentModelID == dog.persistentModelID }
    }

    func save(_ record: HealthRecord) throws {
        if shouldFail { throw MockFailure() }
        items.append(record)
    }

    func delete(_ record: HealthRecord) throws {
        if shouldFail { throw MockFailure() }
        items.removeAll { $0 === record }
    }
}

@MainActor
struct HealthTests {

    @Test func savingThenLoadingReturnsTheItem() throws {
            let repository = MockHealthRepository()
            
            let testDog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25.0)

            let record = HealthRecord(title: "Flea treatment", date: .now)
            record.dog = testDog
            try repository.save(record)
  
            let viewModel = HealthViewModel(repository: repository, dog: testDog)
            viewModel.load()
            #expect(viewModel.records.count == 1)
            #expect(viewModel.errorMessage == nil)
        }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockHealthRepository()
        repository.shouldFail = true
        
        let testDog = Dog(name: "General Peewee", breed: "Lab", ageYears: 3, weightKg: 20.0)

        let viewModel = HealthViewModel(repository: repository, dog: testDog)
        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: Adding records

    @Test func addingARecordSavesItAgainstTheDog() throws {
        let repository = MockHealthRepository()
        let dog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25)

        let record = try AddHealthRecordUseCase(repository: repository)
            .execute(title: "  Rabies vaccine ", date: .now.addingTimeInterval(-3600), nextDueDate: nil, notes: "", kind: .vaccination, dog: dog)

        #expect(record.title == "Rabies vaccine")
        #expect(record.kind == .vaccination)
        #expect(repository.items.count == 1)
    }

    @Test func emptyTitleFutureDateAndEarlyDueDateAreRejected() {
        let repository = MockHealthRepository()
        let dog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25)
        let useCase = AddHealthRecordUseCase(repository: repository)
        let yesterday = Date.now.addingTimeInterval(-86400)

        #expect(throws: HealthError.emptyTitle) {
            try useCase.execute(title: "  ", date: yesterday, nextDueDate: nil, notes: "", kind: .other, dog: dog)
        }
        #expect(throws: HealthError.dateInFuture) {
            try useCase.execute(title: "Vaccine", date: .now.addingTimeInterval(86400 * 3), nextDueDate: nil, notes: "", kind: .other, dog: dog)
        }
        #expect(throws: HealthError.dueDateBeforeRecord) {
            try useCase.execute(title: "Vaccine", date: yesterday, nextDueDate: yesterday.addingTimeInterval(-86400 * 5), notes: "", kind: .other, dog: dog)
        }
        #expect(repository.items.isEmpty)
    }

    @Test func viewModelReportsSuccessOnlyWhenTheRecordSaved() {
        let repository = MockHealthRepository()
        let dog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25)
        let viewModel = HealthViewModel(repository: repository, dog: dog)

        let saved = viewModel.addAHealthRecord(title: "Worming", date: .now.addingTimeInterval(-3600), nextDueDate: nil, notes: "", kind: .worming)
        let rejected = viewModel.addAHealthRecord(title: "", date: .now, nextDueDate: nil, notes: "")

        #expect(saved)
        #expect(rejected == false)
        #expect(viewModel.errorMessage == HealthError.emptyTitle.errorDescription)
        #expect(viewModel.records.count == 1)
    }

    @Test func dueStatusIsOverdueSoonLaterOrNone() {
        let now = Date.now
        let day: TimeInterval = 86400

        #expect(HealthRecord(title: "a", date: now, nextDueDate: now.addingTimeInterval(-3 * day)).dueStatus(asOf: now) == .overdue)
        #expect(HealthRecord(title: "b", date: now, nextDueDate: now.addingTimeInterval(5 * day)).dueStatus(asOf: now) == .dueSoon)
        #expect(HealthRecord(title: "c", date: now, nextDueDate: now.addingTimeInterval(60 * day)).dueStatus(asOf: now) == .later)
        #expect(HealthRecord(title: "d", date: now).dueStatus(asOf: now) == .none)
    }

    @Test func everyRelatedGuideExistsInTheLearnLibrary() {
        let ids = Set(TipLibrary.all.map(\.contentID))

        for kind in HealthRecordKind.allCases {
            if let guideID = kind.relatedGuideID {
                #expect(ids.contains(guideID), "Missing guide for \(kind.name)")
            }
        }
        #expect(ids.contains(TipOfTheDayUseCase.vetGuideID))
    }
}
