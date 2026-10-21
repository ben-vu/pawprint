//
//  HealthTests.swift
//  Health feature tests (Alik)
//
//  Pattern: a mock repository that stores items in an array, then tests
//  that drive the ViewModel or use case through the protocol only.
//

import Foundation
import Testing
@testable import pawprint
import SwiftData

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
        try repository.save(HealthRecord(title: "Flea treatment", date: .now))

        let viewModel = HealthViewModel(repository: repository, dog: <#Dog#>)
        viewModel.load()

        #expect(viewModel.records.count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockHealthRepository()
        repository.shouldFail = true

        let viewModel = HealthViewModel(repository: repository, dog: <#Dog#>)
        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }
}
