//
//  CreateDogUseCase.swift
//  Dashboard feature (Natalie)
//
//  Example use case. One struct per business operation, validation inside,
//  errors as a DomainError enum. Copy this pattern for your own use cases.
//

import Foundation

nonisolated enum DogError: DomainError {
    case emptyName
    case invalidWeight

    var errorDescription: String? {
        switch self {
        case .emptyName: return "Please give your dog a name."
        case .invalidWeight: return "Weight must be more than zero."
        }
    }
}

@MainActor
struct CreateDogUseCase {
    let repository: DogRepository

    func execute(name: String, breed: String, ageYears: Int, weightKg: Double) throws -> Dog {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw DogError.emptyName }
        guard weightKg > 0 else { throw DogError.invalidWeight }

        let dog = Dog(name: trimmed, breed: breed, ageYears: ageYears, weightKg: weightKg)
        try repository.save(dog)
        return dog
    }
}
