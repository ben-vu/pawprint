//
//  DashboardViewModel.swift
//  Dashboard feature (Natalie)
//

import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var dogs: [Dog] = []
    var errorMessage: String?

    private let repository: DogRepository

    init(repository: DogRepository) {
        self.repository = repository
    }

    func load() {
        do {
            dogs = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
