//
//  DashboardTests.swift
//  Dashboard feature tests (Natalie)
//
//  Pattern: a mock repository that stores items in an array, then tests
//  that drive the ViewModel or use case through the protocol only.
//

import Foundation
import Testing
@testable import pawprint

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
        items.append(dog)
    }

    func delete(_ dog: Dog) throws {
        if shouldFail { throw MockFailure() }
        items.removeAll { $0 === dog }
    }
}

@MainActor
struct DashboardTests {

    @Test func savingThenLoadingReturnsTheItem() throws {
        let repository = MockDogRepository()
        try repository.save(Dog(name: "Bella", breed: "Border Collie", ageYears: 3, weightKg: 18.5))

        let viewModel = DashboardViewModel(repository: repository)
        viewModel.load()

        #expect(viewModel.dogs.count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockDogRepository()
        repository.shouldFail = true

        let viewModel = DashboardViewModel(repository: repository)
        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }
}
