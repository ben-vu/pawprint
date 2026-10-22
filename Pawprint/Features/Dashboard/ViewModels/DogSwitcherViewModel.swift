//
//  DogSwitcherViewModel.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  State behind the dog switcher menu shown on the Home, Routines and
//  Health tabs.
//

import Foundation
import Observation

@MainActor
@Observable
final class DogSwitcherViewModel {
    private(set) var dogs: [Dog] = []
    private(set) var activeDog: Dog?
    var errorMessage: String?

    private let repository: DogRepository
    private let resolve = ActiveDogUseCase()

    init(repository: DogRepository) {
        self.repository = repository
    }

    /// Loads the dogs and makes sure the remembered selection points at a real dog.
    func load(selectedID: UUID? = ActiveDogSelection.storedID) {
        do {
            dogs = try repository.fetchAll()
            activeDog = resolve.activeDog(in: dogs, selectedID: selectedID)
            if let activeDog, activeDog.id != selectedID {
                ActiveDogSelection.store(activeDog.id)
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func select(_ dog: Dog) {
        ActiveDogSelection.store(dog.id)
        activeDog = dog
    }
}
