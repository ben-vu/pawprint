//
//  AddDogViewModel.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Form state for adding another dog after onboarding. Saves through
//  CreateDogUseCase so the rules match onboarding exactly.
//

import Foundation
import Observation

@Observable
final class AddDogViewModel {
    var name = ""
    var breed = ""
    var ageYears = 1
    var weightText = ""
    var photoData: Data?
    var errorMessage: String?

    private let createDog: CreateDogUseCase

    init(repository: DogRepository) {
        self.createDog = CreateDogUseCase(repository: repository)
    }

    var weightKg: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    /// Returns the new dog, or nil with `errorMessage` set.
    func save() -> Dog? {
        do {
            let dog = try createDog.execute(name: name, breed: breed, ageYears: ageYears, weightKg: weightKg, photoData: photoData)
            errorMessage = nil
            return dog
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
