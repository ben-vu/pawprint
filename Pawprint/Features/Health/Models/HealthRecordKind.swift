//
//  HealthRecordKind.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//  The kinds of care a record can be, so they can show an icon, suggest a
//  follow-up date and link to the matching Learn guide.
//

import Foundation

nonisolated enum HealthRecordKind: String, CaseIterable, Identifiable, Sendable {
    case vaccination, flea, worming, vetCheckup, grooming, other

    var id: String { rawValue }

    var name: String {
        switch self {
        case .vaccination: return "Vaccination"
        case .flea: return "Flea treatment"
        case .worming: return "Worming"
        case .vetCheckup: return "Vet check-up"
        case .grooming: return "Grooming"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .flea: return "ladybug.fill"
        case .worming: return "pills.fill"
        case .vetCheckup: return "stethoscope"
        case .grooming: return "scissors"
        case .other: return "heart.text.square.fill"
        }
    }

    /// A sensible gap before the next one is due, used to pre-fill the follow-up date.
    var suggestedIntervalDays: Int {
        switch self {
        case .vaccination, .vetCheckup: return 365
        case .flea: return 30
        case .worming: return 90
        case .grooming: return 42
        case .other: return 30
        }
    }

    /// The Learn guide that explains this kind of care.
    var relatedGuideID: String? {
        switch self {
        case .vaccination, .vetCheckup: return "vaccinations-and-vet-check-ups"
        case .flea, .worming: return "fleas-ticks-and-worms"
        case .grooming: return "brushing-and-coat-care"
        case .other: return nil
        }
    }
}

nonisolated enum HealthDueStatus: Equatable, Sendable {
    case none, overdue, dueSoon, later
}
