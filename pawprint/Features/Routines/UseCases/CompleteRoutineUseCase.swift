//
//  CompleteRoutineUseCase.swift
//  Routines feature (Sana)
//
//  Example use case stub. See Dashboard/UseCases/CreateDogUseCase.swift
//  for the full pattern with validation and a DomainError enum.
//

import Foundation

nonisolated enum RoutineError: DomainError {
    case alreadyCompleted

    var errorDescription: String? {
        switch self {
        case .alreadyCompleted: return "This task is already done."
        }
    }
}

@MainActor
struct CompleteRoutineUseCase {
    let repository: RoutineRepository

    func execute(_ task: RoutineTask) throws {
        guard !task.isCompleted else { throw RoutineError.alreadyCompleted }
        task.isCompleted = true
        try repository.save(task)
    }
}
