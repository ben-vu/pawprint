//
//  RoutineRepository.swift
//  Routines feature (Sana)
//

import Foundation
import SwiftData

@MainActor
protocol RoutineRepository {
    func fetchAll() throws -> [RoutineTask]
    func save(_ task: RoutineTask) throws
    func delete(_ task: RoutineTask) throws
}

@MainActor
final class SwiftDataRoutineRepository: RoutineRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [RoutineTask] {
        try context.fetch(FetchDescriptor<RoutineTask>(sortBy: [SortDescriptor(\.dueDate)]))
    }

    func save(_ task: RoutineTask) throws {
        context.insert(task)
        try context.save()
    }

    func delete(_ task: RoutineTask) throws {
        context.delete(task)
        try context.save()
    }
}
