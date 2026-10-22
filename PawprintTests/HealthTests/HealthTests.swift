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
}
