//
//  DogProfileViewModel.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//

import Foundation
import Observation

@Observable
final class DogProfileViewModel {
    let dog: Dog
    var name: String
    var breed: String
    var ageYears: Int
    var weightText: String
    var photoData: Data?
    var careDetails: DogCareDetails
    var errorMessage: String?
    var didSave = false

    private let update: UpdateDogUseCase
    private let remove: DeleteDogUseCase
    private let dogs: DogRepository

    init(dog: Dog, repository: DogRepository) {
        self.dog = dog
        self.name = dog.name
        self.breed = dog.breed
        self.ageYears = dog.ageYears
        self.weightText = dog.weightKg.formatted(.number.precision(.fractionLength(0...1)).grouping(.never))  // no 1,200 style commas, they break parsing
        self.photoData = dog.photoData
        self.careDetails = dog.careDetails
        self.update = UpdateDogUseCase(repository: repository)
        self.remove = DeleteDogUseCase(repository: repository)
        self.dogs = repository
    }

    var weightKg: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    func save() -> Bool {
        do {
            try update.execute(dog, name: name, breed: breed, ageYears: ageYears, weightKg: weightKg, photoData: photoData, careDetails: careDetails)
            errorMessage = nil
            didSave = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// True when no dog profiles remain, so the app should return to onboarding.
    var hasNoDogsLeft: Bool {
        ((try? dogs.fetchAll().count) ?? 0) == 0
    }

    func delete() -> Bool {
        do {
            try remove.execute(dog)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
