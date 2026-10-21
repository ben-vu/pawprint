//
//  LearnTip.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  One beginner guide. `contentID` is the stable identity of the bundled
//  content, so updating the text in a later app version never loses a
//  person's bookmark. Every new property has a default value so existing
//  stores migrate without a manual step.
//

import Foundation
import SwiftData

@Model
final class LearnTip {
    var contentID: String = ""
    var title: String
    /// Raw value of `LearnCategory`. Use `learnCategory` in code.
    var category: String
    var summary: String = ""
    var body: String = ""
    var keyPoints: [String] = []
    var readingMinutes: Int = 2
    var sortOrder: Int = 0
    var isBookmarked: Bool

    init(
        contentID: String = UUID().uuidString,
        title: String,
        category: LearnCategory,
        summary: String = "",
        body: String = "",
        keyPoints: [String] = [],
        readingMinutes: Int = 2,
        sortOrder: Int = 0,
        isBookmarked: Bool = false
    ) {
        self.contentID = contentID
        self.title = title
        self.category = category.rawValue
        self.summary = summary
        self.body = body
        self.keyPoints = keyPoints
        self.readingMinutes = readingMinutes
        self.sortOrder = sortOrder
        self.isBookmarked = isBookmarked
    }

    /// The typed category. Falls back to Getting started if stored text is ever unrecognised.
    var learnCategory: LearnCategory {
        LearnCategory(rawValue: category) ?? .gettingStarted
    }

    /// The article body split into paragraphs for display.
    var paragraphs: [String] {
        body.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
