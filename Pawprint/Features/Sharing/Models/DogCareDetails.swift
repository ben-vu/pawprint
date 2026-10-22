//
//  DogCareDetails.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  The personal details someone looking after the dog needs: who to call,
//  the vet, feeding, medical and behaviour notes. A plain value copy of the
//  matching fields on Dog, so forms and use cases can work with it without
//  touching SwiftData.
//

import Foundation

nonisolated struct DogCareDetails: Equatable, Sendable {
    var ownerName = ""
    var ownerPhone = ""
    var vetName = ""
    var vetPhone = ""
    var microchipNumber = ""
    var feedingNotes = ""
    var medicalNotes = ""
    var behaviourNotes = ""

    /// The longest any single field may be. Keeps a shared sheet readable.
    static let maxLength = 1000

    var isEmpty: Bool { self == DogCareDetails() }

    /// The same details with surrounding spaces and blank lines removed.
    var trimmed: DogCareDetails {
        func clean(_ text: String) -> String {
            text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return DogCareDetails(
            ownerName: clean(ownerName),
            ownerPhone: clean(ownerPhone),
            vetName: clean(vetName),
            vetPhone: clean(vetPhone),
            microchipNumber: clean(microchipNumber),
            feedingNotes: clean(feedingNotes),
            medicalNotes: clean(medicalNotes),
            behaviourNotes: clean(behaviourNotes)
        )
    }

    /// True if any field is longer than `maxLength`.
    var hasTooLongField: Bool {
        [ownerName, ownerPhone, vetName, vetPhone, microchipNumber, feedingNotes, medicalNotes, behaviourNotes]
            .contains { $0.count > Self.maxLength }
    }
}

/// Which parts of the care sheet go into the shared message. The person picks
/// these before sharing, so phone numbers and medical notes only leave the
/// phone when they choose.
nonisolated struct SitterShareOptions: Equatable, Sendable {
    var includeOwnerContact = true
    var includeVet = true
    var includeFeeding = true
    var includeMedical = true
    var includeBehaviour = true
    var includeRoutine = true
    var includeHealthHistory = true
}
