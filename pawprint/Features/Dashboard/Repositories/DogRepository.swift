//
//  DogRepository.swift
//  pawprint
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
        try context.fetch(FetchDescriptor<Dog>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    func save(_ dog: Dog) throws {
        context.insert(dog)
        try context.save()
    }

    func delete(_ dog: Dog) throws {
        context.delete(dog)
        try context.save()
    }
}
