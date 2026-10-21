//
//  LearnTests.swift
//  PawprintTests
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Every test drives a use case or the view model through the repository
//  protocol using an in-memory mock, so nothing touches a real database.
//

import Foundation
import Testing
@testable import Pawprint

@MainActor
final class MockTipRepository: TipRepository {
    var items: [LearnTip] = []
    var failOnFetch = false
    var failOnSave = false

    struct MockFailure: Error {}

    func fetchAll() throws -> [LearnTip] {
        if failOnFetch { throw MockFailure() }
        return items
    }

    func fetchBookmarked() throws -> [LearnTip] {
        if failOnFetch { throw MockFailure() }
        return items.filter { $0.isBookmarked }
    }

    func fetch(category: LearnCategory) throws -> [LearnTip] {
        if failOnFetch { throw MockFailure() }
        return items.filter { $0.learnCategory == category }
    }

    func save(_ tip: LearnTip) throws {
        if failOnSave { throw MockFailure() }
        if !items.contains(where: { $0 === tip }) {
            items.append(tip)
        }
    }

    func delete(_ tip: LearnTip) throws {
        if failOnSave { throw MockFailure() }
        items.removeAll { $0 === tip }
    }
}

@MainActor
struct LearnTests {

    // MARK: Helpers

    private func makeTip(
        _ title: String,
        category: LearnCategory = .feeding,
        summary: String = "",
        body: String = "",
        keyPoints: [String] = [],
        bookmarked: Bool = false
    ) -> LearnTip {
        LearnTip(
            contentID: title.lowercased(),
            title: title,
            category: category,
            summary: summary,
            body: body,
            keyPoints: keyPoints,
            isBookmarked: bookmarked
        )
    }

    private func makeRepository() -> MockTipRepository {
        let repository = MockTipRepository()
        repository.items = [
            makeTip("How much to feed", category: .feeding, body: "Measure portions with a scoop."),
            makeTip("Foods to avoid", category: .feeding, keyPoints: ["Chocolate is toxic"], bookmarked: true),
            makeTip("Brushing basics", category: .grooming, summary: "Keep the coat healthy."),
            makeTip("Sit and stay", category: .training, bookmarked: true)
        ]
        return repository
    }

    // MARK: Filtering

    @Test func filteringByCategoryReturnsOnlyThatCategory() throws {
        let useCase = FilterTipsUseCase(repository: makeRepository())

        let result = try useCase.execute(filter: .category(.feeding))

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.learnCategory == .feeding })
    }

    @Test func bookmarkedFilterReturnsOnlySavedTips() throws {
        let useCase = FilterTipsUseCase(repository: makeRepository())

        let result = try useCase.execute(filter: .bookmarked)

        #expect(Set(result.map(\.title)) == ["Foods to avoid", "Sit and stay"])
    }

    @Test func searchMatchesTitleBodyAndKeyPointsIgnoringCase() throws {
        let useCase = FilterTipsUseCase(repository: makeRepository())

        #expect(try useCase.execute(searchText: "BRUSHING").map(\.title) == ["Brushing basics"])
        #expect(try useCase.execute(searchText: "scoop").map(\.title) == ["How much to feed"])
        #expect(try useCase.execute(searchText: "chocolate").map(\.title) == ["Foods to avoid"])
    }

    @Test func searchRequiresEveryWordToMatch() throws {
        let useCase = FilterTipsUseCase(repository: makeRepository())

        #expect(try useCase.execute(searchText: "feed scoop").count == 1)
        #expect(try useCase.execute(searchText: "feed chocolate").isEmpty)
    }

    @Test func blankSearchReturnsEverything() throws {
        let useCase = FilterTipsUseCase(repository: makeRepository())

        #expect(try useCase.execute(searchText: "   ").count == 4)
    }

    @Test func searchAndCategoryCombine() throws {
        let useCase = FilterTipsUseCase(repository: makeRepository())

        let result = try useCase.execute(filter: .category(.grooming), searchText: "coat")

        #expect(result.map(\.title) == ["Brushing basics"])
    }

    @Test func filterMapsRepositoryFailureToLoadFailed() {
        let repository = makeRepository()
        repository.failOnFetch = true
        let useCase = FilterTipsUseCase(repository: repository)

        #expect(throws: LearnError.loadFailed) {
            try useCase.execute(filter: .all)
        }
    }

    // MARK: Bookmarks

    @Test func togglingBookmarkFlipsStateAndSaves() throws {
        let tip = makeTip("Walk safely")
        let repository = MockTipRepository()
        let useCase = ToggleBookmarkUseCase(repository: repository)

        let first = try useCase.execute(tip)
        let second = try useCase.execute(tip)

        #expect(first == true)
        #expect(second == false)
        #expect(tip.isBookmarked == false)
        #expect(repository.items.count == 1)
    }

    @Test func failedBookmarkSaveRollsBackAndThrowsSaveFailed() {
        let tip = makeTip("Walk safely")
        let repository = MockTipRepository()
        repository.failOnSave = true
        let useCase = ToggleBookmarkUseCase(repository: repository)

        #expect(throws: LearnError.saveFailed) {
            try useCase.execute(tip)
        }
        #expect(tip.isBookmarked == false)
    }

    // MARK: Seeding

    @Test func seedingAddsEveryBundledGuide() throws {
        let repository = MockTipRepository()

        try SeedTipsUseCase(repository: repository).execute()

        #expect(repository.items.count == TipLibrary.all.count)
    }

    @Test func seedingTwiceDoesNotDuplicateGuides() throws {
        let repository = MockTipRepository()
        let useCase = SeedTipsUseCase(repository: repository)

        try useCase.execute()
        try useCase.execute()

        #expect(repository.items.count == TipLibrary.all.count)
    }

    @Test func seedingKeepsBookmarksAndUpdatesChangedText() throws {
        let repository = MockTipRepository()
        let original = TipContent(contentID: "a", title: "Old title", category: .health,
                                  summary: "s", keyPoints: [], body: "body", readingMinutes: 2)
        try SeedTipsUseCase(repository: repository, library: [original]).execute()
        repository.items[0].isBookmarked = true

        let updated = TipContent(contentID: "a", title: "New title", category: .health,
                                 summary: "s", keyPoints: [], body: "body", readingMinutes: 2)
        try SeedTipsUseCase(repository: repository, library: [updated]).execute()

        #expect(repository.items.count == 1)
        #expect(repository.items[0].title == "New title")
        #expect(repository.items[0].isBookmarked == true)
    }

    @Test func seedingRejectsAGuideWithNoBody() {
        let repository = MockTipRepository()
        let broken = TipContent(contentID: "a", title: "Title", category: .health,
                                summary: "", keyPoints: [], body: "  ", readingMinutes: 1)

        #expect(throws: LearnError.invalidTipContent) {
            try SeedTipsUseCase(repository: repository, library: [broken]).execute()
        }
        #expect(repository.items.isEmpty)
    }

    @Test func bundledLibraryCoversEveryCategoryWithUniqueIDs() {
        let ids = TipLibrary.all.map(\.contentID)
        #expect(Set(ids).count == ids.count)
        for category in LearnCategory.allCases {
            #expect(TipLibrary.all.contains { $0.category == category })
        }
    }

    // MARK: View model

    @Test func loadingSeedsGuidesAndShowsThem() {
        let repository = MockTipRepository()
        let viewModel = LearnViewModel(repository: repository)

        viewModel.load()

        #expect(viewModel.tips.count == TipLibrary.all.count)
        #expect(viewModel.hasLoaded)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func changingFilterAndSearchNarrowsTheList() {
        let viewModel = LearnViewModel(repository: MockTipRepository())
        viewModel.load()

        viewModel.selectedFilter = .category(.grooming)
        viewModel.refresh()
        #expect(viewModel.tips.allSatisfy { $0.learnCategory == .grooming })

        viewModel.searchText = "zzzz-no-such-word"
        viewModel.refresh()
        #expect(viewModel.tips.isEmpty)
    }

    @Test func bookmarkingThroughTheViewModelAppearsInSavedFilter() {
        let viewModel = LearnViewModel(repository: MockTipRepository())
        viewModel.load()
        let tip = viewModel.tips[0]

        viewModel.toggleBookmark(tip)
        viewModel.selectedFilter = .bookmarked
        viewModel.refresh()

        #expect(viewModel.tips.count == 1)
        #expect(viewModel.tips.first === tip)
    }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockTipRepository()
        repository.failOnFetch = true
        let viewModel = LearnViewModel(repository: repository)

        viewModel.load()

        #expect(viewModel.errorMessage == LearnError.loadFailed.errorDescription)
    }
}
