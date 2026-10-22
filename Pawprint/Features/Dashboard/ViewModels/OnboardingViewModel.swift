//
//  OnboardingViewModel.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Holds the form while the user walks through onboarding, then saves
//  through CreateDogUseCase so validation lives in one place.
//

import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable { case welcome, details, done }

    var step: Step = .welcome
    var name = "" { didSet { errorMessage = nil } }          // typing clears the red message
    var breed = ""
    var isMixedBreed = false
    var ageYears = 1
    var weightText = "" { didSet { errorMessage = nil } }
    var photoData: Data?
    var errorMessage: String?
    private(set) var savedDog: Dog?

    private let createDog: CreateDogUseCase
    private let suggestBreeds = SuggestBreedsUseCase()

    init(repository: DogRepository) {
        self.createDog = CreateDogUseCase(repository: repository)
    }

    var breedSuggestions: [String] { suggestBreeds.execute(query: breed) }

    var weightKg: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    func next() {
        guard let following = Step(rawValue: step.rawValue + 1) else { return }
        step = following
    }

    func back() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    /// Returns true when the dog saved and we can move on.
    func saveDog() -> Bool {
        do {
            savedDog = try createDog.execute(name: name, breed: breed, ageYears: ageYears, weightKg: weightKg, photoData: photoData, isMixedBreed: isMixedBreed)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
