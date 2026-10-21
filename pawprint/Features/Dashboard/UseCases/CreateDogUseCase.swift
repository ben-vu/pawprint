//
//  CreateDogUseCase.swift
//  pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Example use case. One struct per business operation, validation inside,
//  errors as a DomainError enum. Copy this pattern for your own use cases.
//

import Foundation

nonisolated enum DogError: DomainError {
    case emptyName
    case invalidWeight
    case invalidAge

    var errorDescription: String? {
        switch self {
        case .emptyName: return "Please give your dog a name."
        case .invalidWeight: return "Weight must be between 0.1 and 150 kg."
        case .invalidAge: return "Age should be between 0 and 30 years."
        }
    }
}

@MainActor
struct CreateDogUseCase {
    let repository: DogRepository

    func execute(name: String, breed: String, ageYears: Int, weightKg: Double, photoData: Data? = nil) throws -> Dog {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw DogError.emptyName }
        guard (0.1...150).contains(weightKg) else { throw DogError.invalidWeight }   // heaviest breeds top out around 100 kg
        guard (0...30).contains(ageYears) else { throw DogError.invalidAge }

        let dog = Dog(name: trimmed, breed: breed.trimmingCharacters(in: .whitespaces), ageYears: ageYears, weightKg: weightKg, photoData: photoData)
        try repository.save(dog)
        return dog
    }
}
