//
//  DogRepository.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Protocol first, SwiftData second. ViewModels and use cases only ever
//  see the protocol, so tests can swap in a mock.
//

import Foundation
import SwiftData

@MainActor
protocol DogRepository {
    func fetchAll() throws -> [Dog]
    func save(_ dog: Dog) throws
    func delete(_ dog: Dog) throws
}

@MainActor
final class SwiftDataDogRepository: DogRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Dog] {
        do { return try context.fetch(FetchDescriptor<Dog>(sortBy: [SortDescriptor(\.createdAt)])) }
        catch { throw RepositoryStorageError.readFailed }
    }

    func save(_ dog: Dog) throws {
        do {
            context.insert(dog)
            try context.save()
        } catch { throw RepositoryStorageError.saveFailed }
        NotificationCenter.default.post(name: .pawprintDogsDidChange, object: nil)
    }

    func delete(_ dog: Dog) throws {
        do {
            context.delete(dog)
            try context.save()
        } catch { throw RepositoryStorageError.deleteFailed }
        NotificationCenter.default.post(name: .pawprintDogsDidChange, object: nil)
    }
}
