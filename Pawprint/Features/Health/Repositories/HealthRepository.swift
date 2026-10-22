//
//  HealthRepository.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//

import Foundation
import SwiftData

@MainActor
protocol HealthRepository {
    func fetchRecords(for dog: Dog) throws -> [HealthRecord]
    func save(_ record: HealthRecord) throws
    func delete(_ record: HealthRecord) throws
}

@MainActor
class SwiftDataHealthRepository: HealthRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchRecords(for dog: Dog) throws -> [HealthRecord] {
        let allRecords = try context.fetch(FetchDescriptor<HealthRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
        
        return allRecords.filter { $0.dog?.persistentModelID == dog.persistentModelID }
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
