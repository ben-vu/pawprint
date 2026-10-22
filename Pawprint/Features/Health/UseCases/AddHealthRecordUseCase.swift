//
//  AddHealthRecordUseCase.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//  Validates and saves a vaccination, treatment, check-up or grooming
//  record for one dog.
//

import Foundation

@MainActor
struct AddHealthRecordUseCase {
    let repository: HealthRepository

    @discardableResult
    func execute(
        title: String,
        date: Date,
        nextDueDate: Date?,
        notes: String,
        kind: HealthRecordKind,
        dog: Dog,
        now: Date = .now
    ) throws -> HealthRecord {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw HealthError.emptyTitle }
        guard date <= now else { throw HealthError.dateInFuture }
        if let nextDueDate, Calendar.current.startOfDay(for: nextDueDate) < Calendar.current.startOfDay(for: date) {
            throw HealthError.dueDateBeforeRecord
        }

        let record = HealthRecord(
            title: trimmed,
            date: date,
            nextDueDate: nextDueDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            dog: dog,
            kind: kind
        )
        try repository.save(record)
        return record
    }
}
