//
//  TipContent.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  A plain value describing one bundled guide. TipLibrary holds these and
//  SeedTipsUseCase turns them into persisted LearnTip models.
//

import Foundation

nonisolated struct TipContent: Sendable, Equatable {
    let contentID: String
    let title: String
    let category: LearnCategory
    let summary: String
    let keyPoints: [String]
    let body: String
    let readingMinutes: Int
}
