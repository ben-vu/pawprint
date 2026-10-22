//
//  HealthDueItem.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  A health record reduced to what the widget rule needs: what was done,
//  when, for which dog and when the follow-up is due.
//

import Foundation

nonisolated struct HealthDueItem: Equatable, Sendable {
    let title: String
    let recordDate: Date
    let nextDueDate: Date?
    let dogName: String?
    let dogID: UUID?
}
