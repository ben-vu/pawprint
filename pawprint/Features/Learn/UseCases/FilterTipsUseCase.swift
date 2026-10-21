//
//  FilterTipsUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Browse by category or saved tips, then narrow by what was typed into the
//  search bar. Every typed word must appear somewhere in the guide (title,
//  summary, key points or body), ignoring case and accents, so
//  "puppy toilet" finds the toilet training guide.
//

import Foundation

@MainActor
struct FilterTipsUseCase {
    let repository: TipRepository

    func execute(filter: LearnFilter = .all, searchText: String = "") throws -> [LearnTip] {
        let candidates: [LearnTip]
        do {
            switch filter {
            case .all:
                candidates = try repository.fetchAll()
            case .bookmarked:
                candidates = try repository.fetchBookmarked()
            case .category(let category):
                candidates = try repository.fetch(category: category)
            }
        } catch {
            throw LearnError.loadFailed
        }

        let terms = Self.searchTerms(from: searchText)
        guard !terms.isEmpty else { return candidates }

        return candidates.filter { tip in
            let searchable = ([tip.title, tip.summary, tip.body] + tip.keyPoints)
                .joined(separator: " ")
            return terms.allSatisfy { searchable.localizedStandardContains($0) }
        }
    }

    static func searchTerms(from text: String) -> [String] {
        text.split(whereSeparator: { $0.isWhitespace }).map { String($0) }
    }
}
