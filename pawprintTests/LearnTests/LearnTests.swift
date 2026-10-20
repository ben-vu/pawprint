//
//  LearnTests.swift
//  Learn feature tests (Ben)
//
//  Pattern: a mock repository that stores items in an array, then tests
//  that drive the ViewModel or use case through the protocol only.
//

import Foundation
import Testing
@testable import pawprint

@MainActor
final class MockTipRepository: TipRepository {
    var items: [LearnTip] = []
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchAll() throws -> [LearnTip] {
        if shouldFail { throw MockFailure() }
        return items
    }

    func save(_ tip: LearnTip) throws {
        if shouldFail { throw MockFailure() }
        items.append(tip)
    }

    func delete(_ tip: LearnTip) throws {
        if shouldFail { throw MockFailure() }
        items.removeAll { $0 === tip }
    }
}

@MainActor
struct LearnTests {

    @Test func savingThenLoadingReturnsTheItem() throws {
        let repository = MockTipRepository()
        try repository.save(LearnTip(title: "Brushing basics", category: "grooming"))

        let viewModel = LearnViewModel(repository: repository)
        viewModel.load()

        #expect(viewModel.tips.count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockTipRepository()
        repository.shouldFail = true

        let viewModel = LearnViewModel(repository: repository)
        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }
}
