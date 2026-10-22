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
    var isMixedBreed: Bool
    var ageYears: Int
    var weightText: String
    var photoData: Data?
    var errorMessage: String?
    var didSave = false

    private let update: UpdateDogUseCase
    private let remove: DeleteDogUseCase
    private let suggestBreeds = SuggestBreedsUseCase()

    var breedSuggestions: [String] { suggestBreeds.execute(query: breed) }

    init(dog: Dog, repository: DogRepository) {
        self.dog = dog
        self.name = dog.name
        self.breed = dog.breed
        self.isMixedBreed = dog.isMixedBreed
        self.ageYears = dog.ageYears
        self.weightText = dog.weightKg.formatted(.number.precision(.fractionLength(0...1)).grouping(.never))  // no 1,200 style commas, they break parsing
        self.photoData = dog.photoData
        self.update = UpdateDogUseCase(repository: repository)
        self.remove = DeleteDogUseCase(repository: repository)
    }

    var weightKg: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    func save() -> Bool {
        do {
            try update.execute(dog, name: name, breed: breed, ageYears: ageYears, weightKg: weightKg, photoData: photoData, isMixedBreed: isMixedBreed)
            errorMessage = nil
            didSave = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
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
