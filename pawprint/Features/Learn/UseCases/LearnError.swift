//
//  LearnError.swift
//  pawprint
//
//  Created by Benjamin Vu on 21/10/2026
//
//  Repository errors are mapped to these in the use cases, so the UI only
//  ever shows plain-language messages and never a storage error.
//

import Foundation

nonisolated enum LearnError: DomainError {
    case loadFailed
    case saveFailed
    case invalidTipContent

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "We couldn't load the tips. Please close and reopen Pawprint."
        case .saveFailed:
            return "We couldn't save your change. Please try again."
        case .invalidTipContent:
            return "Some of the built-in guides are incomplete."
        }
    }
}
