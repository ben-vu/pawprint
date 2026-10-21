//
//  LearnCategory.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  The topics tips are organised under. A closed enum means a tip can never
//  end up in a category that does not exist.
//

import Foundation

nonisolated enum LearnCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case gettingStarted
    case feeding
    case exercise
    case training
    case grooming
    case health

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gettingStarted: return "Getting started"
        case .feeding: return "Feeding"
        case .exercise: return "Exercise"
        case .training: return "Training"
        case .grooming: return "Grooming"
        case .health: return "Health"
        }
    }

    var systemImage: String {
        switch self {
        case .gettingStarted: return "pawprint.fill"
        case .feeding: return "fork.knife"
        case .exercise: return "figure.walk"
        case .training: return "graduationcap.fill"
        case .grooming: return "scissors"
        case .health: return "cross.case.fill"
        }
    }
}
