//
//  LearnTip.swift
//  Learn feature (Ben)
//
//  Starter model. Add body text, categories and whatever else you need.
//

import Foundation
import SwiftData

@Model
final class LearnTip {
    var title: String
    var category: String
    var isBookmarked: Bool

    init(title: String, category: String, isBookmarked: Bool = false) {
        self.title = title
        self.category = category
        self.isBookmarked = isBookmarked
    }
}
