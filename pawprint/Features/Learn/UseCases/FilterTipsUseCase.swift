//
//  FilterTipsUseCase.swift
//  Learn feature (Ben)
//
//  Example use case stub. See Dashboard/UseCases/CreateDogUseCase.swift
//  for the full pattern with validation and a DomainError enum.
//

import Foundation

nonisolated enum LearnError: DomainError {
    case unknownCategory

    var errorDescription: String? {
        switch self {
        case .unknownCategory: return "That category doesn't exist."
        }
    }
}

@MainActor
struct FilterTipsUseCase {
    let repository: TipRepository

    func execute(category: String) throws -> [LearnTip] {
        try repository.fetchAll().filter { $0.category == category }
    }
}
