//
//  OverdueTreatmentsUseCase.swift
//  Health feature (Alik)
//
//  Example use case stub. See Dashboard/UseCases/CreateDogUseCase.swift
//  for the full pattern with validation and a DomainError enum.
//

import Foundation

nonisolated enum HealthError: DomainError {
    case dateInFuture

    var errorDescription: String? {
        switch self {
        case .dateInFuture: return "A record date can't be in the future."
        }
    }
}

@MainActor
struct OverdueTreatmentsUseCase {
    let repository: HealthRepository

    func execute(asOf today: Date = .now) throws -> [HealthRecord] {
        try repository.fetchAll().filter { record in
            guard let due = record.nextDueDate else { return false }
            return due < today
        }
    }
}
