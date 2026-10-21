//
//  TipRepository.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026
//
//  Use cases and view models only ever see the protocol, so tests can swap
//  in an in-memory mock and nothing above this file imports SwiftData.
//

import Foundation
import SwiftData

@MainActor
protocol TipRepository {
    func fetchAll() throws -> [LearnTip]
    func fetchBookmarked() throws -> [LearnTip]
    func fetch(category: LearnCategory) throws -> [LearnTip]
    func save(_ tip: LearnTip) throws
    func delete(_ tip: LearnTip) throws
}

@MainActor
final class SwiftDataTipRepository: TipRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Curated order first, then alphabetical as a tie-break.
    private var displayOrder: [SortDescriptor<LearnTip>] {
        [SortDescriptor(\.sortOrder), SortDescriptor(\.title)]
    }

    func fetchAll() throws -> [LearnTip] {
        try context.fetch(FetchDescriptor<LearnTip>(sortBy: displayOrder))
    }

    func fetchBookmarked() throws -> [LearnTip] {
        let descriptor = FetchDescriptor<LearnTip>(
            predicate: #Predicate<LearnTip> { $0.isBookmarked },
            sortBy: displayOrder
        )
        return try context.fetch(descriptor)
    }

    func fetch(category: LearnCategory) throws -> [LearnTip] {
        let rawValue = category.rawValue
        let descriptor = FetchDescriptor<LearnTip>(
            predicate: #Predicate<LearnTip> { $0.category == rawValue },
            sortBy: displayOrder
        )
        return try context.fetch(descriptor)
    }

    func save(_ tip: LearnTip) throws {
        context.insert(tip)
        try context.save()
    }

    func delete(_ tip: LearnTip) throws {
        context.delete(tip)
        try context.save()
    }
}
