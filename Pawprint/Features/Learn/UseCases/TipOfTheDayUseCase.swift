//
//  TipOfTheDayUseCase.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Picks one guide per day for the widget. The guide changes every day and
//  cycles through the whole library. If a vaccination, treatment or
//  check-up is due soon, today's guide is the vet care guide instead, which
//  is how Health and Learn meet in the widget.
//
//  It plans a week ahead so the widget can show a new tip each morning
//  without the app having to run.
//

import Foundation

@MainActor
struct TipOfTheDayUseCase {
    static let vetGuideID = "vaccinations-and-vet-check-ups"

    var calendar: Calendar = .current

    func execute(tips: [LearnTip], from start: Date, days: Int = 7, preferVetGuide: Bool = false) -> [WidgetTip] {
        guard !tips.isEmpty else { return [] }
        let ordered = tips.sorted { $0.sortOrder < $1.sortOrder }
        let firstDay = calendar.startOfDay(for: start)

        return (0..<days).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: firstDay) else { return nil }
            let ordinal = calendar.ordinality(of: .day, in: .era, for: day) ?? offset
            var tip = ordered[ordinal % ordered.count]
            if offset == 0, preferVetGuide, let vetGuide = ordered.first(where: { $0.contentID == Self.vetGuideID }) {
                tip = vetGuide
            }
            return WidgetTip(
                contentID: tip.contentID,
                title: tip.title,
                summary: tip.summary,
                categoryTitle: tip.learnCategory.title,
                categoryImage: tip.learnCategory.systemImage,
                day: day
            )
        }
    }
}
