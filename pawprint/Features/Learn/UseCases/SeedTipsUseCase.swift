//
//  SeedTipsUseCase.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026
//
//  Copies the bundled guides into the database. Safe to run on every launch:
//  new guides are added, changed guides are updated, unchanged guides are
//  left alone, and bookmarks are never touched.
//

import Foundation

@MainActor
struct SeedTipsUseCase {
    let repository: TipRepository
    var library: [TipContent] = TipLibrary.all

    func execute() throws {
        try validateLibrary()

        let existing: [LearnTip]
        do {
            existing = try repository.fetchAll()
        } catch {
            throw LearnError.loadFailed
        }
        let existingByID = Dictionary(
            existing.map { ($0.contentID, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        do {
            for (index, content) in library.enumerated() {
                if let tip = existingByID[content.contentID] {
                    guard Self.differs(tip, from: content, sortOrder: index) else { continue }
                    tip.title = content.title
                    tip.category = content.category.rawValue
                    tip.summary = content.summary
                    tip.body = content.body
                    tip.keyPoints = content.keyPoints
                    tip.readingMinutes = content.readingMinutes
                    tip.sortOrder = index
                    try repository.save(tip)
                } else {
                    let tip = LearnTip(
                        contentID: content.contentID,
                        title: content.title,
                        category: content.category,
                        summary: content.summary,
                        body: content.body,
                        keyPoints: content.keyPoints,
                        readingMinutes: content.readingMinutes,
                        sortOrder: index
                    )
                    try repository.save(tip)
                }
            }
        } catch {
            throw LearnError.saveFailed
        }
    }

    private func validateLibrary() throws {
        var seen = Set<String>()
        for content in library {
            let hasText = !content.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !content.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            guard hasText, !content.contentID.isEmpty, seen.insert(content.contentID).inserted else {
                throw LearnError.invalidTipContent
            }
        }
    }

    private static func differs(_ tip: LearnTip, from content: TipContent, sortOrder: Int) -> Bool {
        tip.title != content.title
            || tip.category != content.category.rawValue
            || tip.summary != content.summary
            || tip.body != content.body
            || tip.keyPoints != content.keyPoints
            || tip.readingMinutes != content.readingMinutes
            || tip.sortOrder != sortOrder
    }
}
