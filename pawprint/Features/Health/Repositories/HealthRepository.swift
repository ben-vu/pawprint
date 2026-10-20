//
//  HealthRepository.swift
//  Health feature (Alik)
//

import Foundation
import SwiftData

@MainActor
protocol HealthRepository {
    func fetchAll() throws -> [HealthRecord]
    func save(_ record: HealthRecord) throws
    func delete(_ record: HealthRecord) throws
}

@MainActor
final class SwiftDataHealthRepository: HealthRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [HealthRecord] {
        try context.fetch(FetchDescriptor<HealthRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
    }

    func save(_ record: HealthRecord) throws {
        context.insert(record)
        try context.save()
    }

    func delete(_ record: HealthRecord) throws {
        context.delete(record)
        try context.save()
    }
}
