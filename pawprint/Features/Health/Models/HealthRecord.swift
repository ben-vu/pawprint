//
//  HealthRecord.swift
//  Health feature (Alik)
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

    init(title: String, date: Date, nextDueDate: Date? = nil, notes: String = "", dog: Dog? = nil) {
        self.title = title
        self.date = date
        self.nextDueDate = nextDueDate
        self.notes = notes
        self.dog = dog
    }
}
