//
//  ActiveDogSelection.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Remembers which dog the person is looking after right now. Every tab
//  reads this, so switching dog on one tab switches it everywhere.
//

import Foundation

nonisolated enum ActiveDogSelection {
    static let storageKey = "selectedDogID"

    static var storedID: UUID? {
        UserDefaults.standard.string(forKey: storageKey).flatMap { UUID(uuidString: $0) }
    }

    static func store(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: storageKey)
    }
}
