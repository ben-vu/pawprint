//
//  ShareDogViewModel.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  State behind the "Share with a sitter" sheet: which parts to include and
//  the care sheet text that results. Loads the dog's routines and health
//  records through the repositories, so tests can use mocks.
//

import Foundation
import Observation

@MainActor
@Observable
final class ShareDogViewModel {
    let dog: Dog
    var options = SitterShareOptions()
    var errorMessage: String?
    private(set) var routines: [RoutineTask] = []
    private(set) var healthRecords: [HealthRecord] = []

    private let routineRepository: RoutineRepository
    private let healthRepository: HealthRepository
    private let buildSummary = BuildSitterSummaryUseCase()

    init(dog: Dog, routines: RoutineRepository, health: HealthRepository) {
        self.dog = dog
        self.routineRepository = routines
        self.healthRepository = health
    }

    func load() {
        do {
            routines = try routineRepository.fetchAll()
            healthRecords = try healthRepository.fetchRecords(for: dog)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// The text that will be shared, rebuilt whenever an option or the dog changes.
    var summary: String {
        buildSummary.execute(dog: dog, routines: routines, healthRecords: healthRecords, options: options)
    }

    var subject: String { "\(dog.name): care sheet" }

    /// False until the person has filled in at least one care detail, so the sheet can nudge them to.
    var hasCareDetails: Bool { !dog.careDetails.isEmpty }
}
