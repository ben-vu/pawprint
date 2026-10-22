//
//  LearnViewModel.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Single source of truth for the Learn tab. Views read `tips` and call the
//  methods below; all rules live in the use cases.
//

import Foundation
import Observation

@MainActor
@Observable
final class LearnViewModel {
    private(set) var tips: [LearnTip] = []
    private(set) var hasLoaded = false
    var selectedFilter: LearnFilter = .all
    var searchText = ""
    var errorMessage: String?

    private let seedTipsUseCase: SeedTipsUseCase
    private let filterTipsUseCase: FilterTipsUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase

    init(repository: TipRepository) {
        seedTipsUseCase = SeedTipsUseCase(repository: repository)
        filterTipsUseCase = FilterTipsUseCase(repository: repository)
        toggleBookmarkUseCase = ToggleBookmarkUseCase(repository: repository)
    }

    /// Makes sure the bundled guides exist, then loads the current view.
    func load() {
        do {
            try seedTipsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        refresh()
        hasLoaded = true
    }

    /// Re-runs the current filter and search.
    func refresh() {
        do {
            tips = try filterTipsUseCase.execute(filter: selectedFilter, searchText: searchText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Finds a guide by its content ID, ignoring the current filter and search.
    /// Used when a widget or the Health tab links straight to a guide.
    func tip(withContentID contentID: String) -> LearnTip? {
        (try? filterTipsUseCase.execute(filter: .all))?.first { $0.contentID == contentID }
    }

    func toggleBookmark(_ tip: LearnTip) {
        do {
            try toggleBookmarkUseCase.execute(tip)
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
