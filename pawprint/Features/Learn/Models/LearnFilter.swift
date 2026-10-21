//
//  LearnFilter.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026
//
//  What the person is currently browsing: everything, their saved tips,
//  or a single category.
//

import Foundation

nonisolated enum LearnFilter: Hashable, Identifiable, Sendable {
    case all
    case bookmarked
    case category(LearnCategory)

    var id: LearnFilter { self }

    var title: String {
        switch self {
        case .all: return "All"
        case .bookmarked: return "Saved"
        case .category(let category): return category.title
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .bookmarked: return "bookmark.fill"
        case .category(let category): return category.systemImage
        }
    }

    /// Every filter in the order the chips are shown.
    static var allFilters: [LearnFilter] {
        [.all, .bookmarked] + LearnCategory.allCases.map { LearnFilter.category($0) }
    }
}
