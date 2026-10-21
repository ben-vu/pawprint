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
    
    func addAHealthRecord() {
        
    }
}
