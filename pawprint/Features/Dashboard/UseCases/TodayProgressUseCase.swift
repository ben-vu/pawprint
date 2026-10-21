//
//  TodayProgressUseCase.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Works out how many of today's routine tasks are done. Reads Sana's
//  RoutineTask through her repository protocol, never directly.
//

import Foundation

nonisolated struct TodayProgress: Equatable {
    let completed: Int
    let total: Int

    var fraction: Double { total == 0 ? 0 : Double(completed) / Double(total) }
    var isAllDone: Bool { total > 0 && completed == total }
}

struct TodayProgressUseCase {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func execute(tasks: [RoutineTask], on day: Date = .now) -> TodayProgress {
        let todays = tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: day) }
        return TodayProgress(
            completed: todays.filter(\.isCompleted).count,
            total: todays.count
        )
    }
}
