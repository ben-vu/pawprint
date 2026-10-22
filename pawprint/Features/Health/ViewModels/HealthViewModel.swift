//
//  HealthViewModel.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//

import Foundation
import Observation

@MainActor
@Observable
class HealthViewModel {
    private(set) var records: [HealthRecord] = []
    var errorMessage: String?
    let dog: Dog

    private let repository: HealthRepository

    init(repository: HealthRepository, dog: Dog) {
        self.repository = repository
        self.dog = dog
    }

    func load() {
        do {
            records = try repository.fetchRecords(for: dog)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Returns true when the record saved, so the form only closes on success.
    @discardableResult
    func addAHealthRecord(title: String, date: Date, nextDueDate: Date?, notes: String, kind: HealthRecordKind = .other) -> Bool {
        do {
            try AddHealthRecordUseCase(repository: repository)
                .execute(title: title, date: date, nextDueDate: nextDueDate, notes: notes, kind: kind, dog: dog)
            errorMessage = nil
            load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ record: HealthRecord) {
        do {
            try repository.delete(record)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
