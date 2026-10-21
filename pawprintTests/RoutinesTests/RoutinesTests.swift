//
//  RoutinesTests.swift
//  pawprintTests
//
//  Created by Natalie Michael on 20/10/2026.
//
//  Pattern: a mock repository that stores items in an array, then tests
//  that drive the ViewModel or use case through the protocol only.
//

import Foundation
import Testing
@testable import pawprint

@MainActor
final class MockRoutineRepository: RoutineRepository {
    var items: [RoutineTask] = []
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchAll() throws -> [RoutineTask] {
        if shouldFail { throw MockFailure() }
        return items
    }

    func save(_ task: RoutineTask) throws {
        if shouldFail { throw MockFailure() }
        items.append(task)
    }

    func delete(_ task: RoutineTask) throws {
        if shouldFail { throw MockFailure() }
        items.removeAll { $0 === task }
    }
}

@MainActor
struct RoutinesTests {

    @Test func savingThenLoadingReturnsTheItem() throws {
        let repository = MockRoutineRepository()
        try repository.save(RoutineTask(title: "Morning walk", dueDate: .now))

        let viewModel = RoutineViewModel(repository: repository)
        viewModel.load()

        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockRoutineRepository()
        repository.shouldFail = true

        let viewModel = RoutineViewModel(repository: repository)
        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }
}
