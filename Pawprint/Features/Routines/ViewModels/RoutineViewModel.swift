//
//  RoutineViewModel.swift
//  Routines feature (Sana)
//

import Foundation
import Observation

@MainActor
@Observable
final class RoutineViewModel {
    private(set) var tasks: [RoutineTask] = []
    var errorMessage: String?

    private let repository: RoutineRepository

    init(repository: RoutineRepository) {
        self.repository = repository
    }

    func load() {
        do {
            tasks = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
