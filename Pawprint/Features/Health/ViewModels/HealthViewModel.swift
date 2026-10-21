//
//  HealthViewModel.swift
//  Health feature (Alik)
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
    
    func addAHealthRecord(title: String, date: Date, nextDueDate: Date?, notes: String) {
        if date > Date() {
            self.errorMessage = HealthError.dateInFuture.errorDescription
            return
        }
        
        let newHealthRecord = HealthRecord(
            title: title,
            date: date,
            nextDueDate: nextDueDate,
            notes: notes,
            dog: dog
        )
        
        do {
            try repository.save(newHealthRecord)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
