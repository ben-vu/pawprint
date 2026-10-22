//
//  OverdueTreatmentsUseCase.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//
//  Example use case stub. See Dashboard/UseCases/CreateDogUseCase.swift
//  for the full pattern with validation and a DomainError enum.
//

import Foundation

nonisolated enum HealthError: DomainError {
    case dateInFuture
    case emptyTitle
    case dueDateBeforeRecord

    var errorDescription: String? {
        switch self {
        case .dateInFuture: return "A record date can't be in the future."
        case .emptyTitle: return "Please say what was done, for example Rabies vaccine."
        case .dueDateBeforeRecord: return "The next due date can't be before the date given."
        }
    }
}

@MainActor
struct OverdueTreatmentsUseCase {
    let repository: HealthRepository

    func execute(for dog: Dog, asOf today: Date = .now) throws -> [HealthRecord] {
        let records = try repository.fetchRecords(for: dog)
        return records.filter { record in
                    guard let due = record.nextDueDate else { return false }
                    return due < today
        }
    }
}
