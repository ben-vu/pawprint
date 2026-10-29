//
//  RoutineRepository.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
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
        do { return try context.fetch(FetchDescriptor<RoutineTask>(sortBy: [SortDescriptor(\.dueDate)])) }
        catch { throw RepositoryStorageError.readFailed }
    }

    func save(_ task: RoutineTask) throws {
        do {
            context.insert(task)
            try context.save()
        } catch { throw RepositoryStorageError.saveFailed }
    }

    func delete(_ task: RoutineTask) throws {
        do {
            context.delete(task)
            try context.save()
        } catch { throw RepositoryStorageError.deleteFailed }
    }
}
