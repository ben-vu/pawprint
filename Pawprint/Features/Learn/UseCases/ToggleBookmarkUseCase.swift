//
//  ToggleBookmarkUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Saves or un-saves a tip. If the save fails the in-memory change is put
//  back, so the bookmark icon never shows something that was not stored.
//

import Foundation

@MainActor
struct ToggleBookmarkUseCase {
    let repository: TipRepository

    /// Returns the new bookmarked state.
    @discardableResult
    func execute(_ tip: LearnTip) throws -> Bool {
        let newValue = !tip.isBookmarked
        tip.isBookmarked = newValue
        do {
            try repository.save(tip)
        } catch {
            tip.isBookmarked = !newValue
            throw LearnError.saveFailed
        }
        return newValue
    }
}
