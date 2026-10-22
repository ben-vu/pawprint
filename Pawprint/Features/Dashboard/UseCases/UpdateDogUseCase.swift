//
//  UpdateDogUseCase.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Edits an existing dog with the same rules as creating one. Care details
//  (owner, vet, notes for a sitter) are optional: pass nil to leave them as they are.
//

import Foundation

struct UpdateDogUseCase {
    let repository: DogRepository

    func execute(_ dog: Dog, name: String, breed: String, ageYears: Int, weightKg: Double, photoData: Data?, careDetails: DogCareDetails? = nil) throws {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw DogError.emptyName }
        guard (0.1...150).contains(weightKg) else { throw DogError.invalidWeight }   // heaviest breeds top out around 100 kg
        guard (0...30).contains(ageYears) else { throw DogError.invalidAge }
        if let careDetails, careDetails.hasTooLongField { throw DogError.detailTooLong }
        let nameTaken = try repository.fetchAll().contains { $0 !== dog && $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }
        guard !nameTaken else { throw DogError.duplicateName(trimmed) }

        dog.name = trimmed
        dog.breed = breed.trimmingCharacters(in: .whitespaces)
        dog.ageYears = ageYears
        dog.weightKg = weightKg
        dog.photoData = photoData
        if let careDetails { dog.careDetails = careDetails.trimmed }
        try repository.save(dog)
    }
}
