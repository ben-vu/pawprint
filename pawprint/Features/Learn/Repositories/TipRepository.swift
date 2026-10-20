//
//  TipRepository.swift
//  Learn feature (Ben)
//

import Foundation
import SwiftData

@MainActor
protocol TipRepository {
    func fetchAll() throws -> [LearnTip]
    func save(_ tip: LearnTip) throws
    func delete(_ tip: LearnTip) throws
}

@MainActor
final class SwiftDataTipRepository: TipRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [LearnTip] {
        try context.fetch(FetchDescriptor<LearnTip>(sortBy: [SortDescriptor(\.title)]))
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
