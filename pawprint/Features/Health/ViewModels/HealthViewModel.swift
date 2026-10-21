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

    private let repository: HealthRepository

    init(repository: HealthRepository) {
        self.repository = repository
    }

    func load() {
        do {
            records = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
