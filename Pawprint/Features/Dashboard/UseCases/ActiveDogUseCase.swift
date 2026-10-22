//
//  ActiveDogUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Works out which dog is active and which routines belong on screen.
//  If the remembered dog no longer exists (for example it was removed),
//  the first dog is used instead, so the app never shows an empty state
//  while a dog exists.
//

import Foundation

@MainActor
struct ActiveDogUseCase {
    func activeDog(in dogs: [Dog], selectedID: UUID?) -> Dog? {
        dogs.first { $0.id == selectedID } ?? dogs.first
    }

    /// Routines or records with no dog (older data) show for every dog.
    nonisolated static func shows(taskDogID: UUID?, activeDogID: UUID?) -> Bool {
        guard let taskDogID, let activeDogID else { return true }
        return taskDogID == activeDogID
    }
}
