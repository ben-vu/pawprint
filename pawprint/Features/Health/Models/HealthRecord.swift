//
//  HealthRecord.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//  Starter model. Add record types, due dates and whatever else you need.
//

import Foundation
import SwiftData

@Model
class HealthRecord {
    var title: String
    var date: Date
    var nextDueDate: Date?
    var notes: String
    var dog: Dog?
    var kindRaw: String = HealthRecordKind.other.rawValue   // default so existing records migrate

    init(title: String, date: Date, nextDueDate: Date? = nil, notes: String = "", dog: Dog? = nil, kind: HealthRecordKind = .other) {
        self.title = title
        self.date = date
        self.nextDueDate = nextDueDate
        self.notes = notes
        self.dog = dog
        self.kindRaw = kind.rawValue
    }

    var kind: HealthRecordKind {
        get { HealthRecordKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }

    /// Overdue, due within two weeks, due later, or no follow-up planned.
    func dueStatus(asOf now: Date = .now, calendar: Calendar = .current) -> HealthDueStatus {
        guard let due = nextDueDate else { return .none }
        if calendar.startOfDay(for: due) < calendar.startOfDay(for: now) { return .overdue }
        let soon = calendar.date(byAdding: .day, value: 14, to: now) ?? now
        return due <= soon ? .dueSoon : .later
    }
}
