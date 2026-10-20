//
//  LearnViewModel.swift
//  Learn feature (Ben)
//

import Foundation
import Observation

@MainActor
@Observable
final class LearnViewModel {
    private(set) var tips: [LearnTip] = []
    var errorMessage: String?

    private let repository: TipRepository

    init(repository: TipRepository) {
        self.repository = repository
    }

    func load() {
        do {
            tips = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
