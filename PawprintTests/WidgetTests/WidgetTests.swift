//
//  WidgetTests.swift
//  PawprintTests
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Covers the rules that decide what the Home Screen widget shows, using a
//  mock task repository, an in-memory snapshot store and a mock reloader.
//

import Foundation
import Testing
import SwiftData
@testable import Pawprint

@MainActor
final class MockUpcomingTaskRepository: UpcomingTaskRepository {
    var tasks: [UpcomingTask] = []
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchIncompleteTasks() throws -> [UpcomingTask] {
        if shouldFail { throw MockFailure() }
        return tasks
    }
}

nonisolated final class InMemoryWidgetSnapshotStore: WidgetSnapshotStore {
    var snapshot = WidgetSnapshot.empty
    var saveCount = 0
    var error: WidgetSyncError?

    func load() -> WidgetSnapshot { snapshot }

    func save(_ snapshot: WidgetSnapshot) throws {
        if let error { throw error }
        self.snapshot = snapshot
        saveCount += 1
    }
}

@MainActor
final class MockWidgetReloader: WidgetReloading {
    var reloadCount = 0
    func reloadTimelines() { reloadCount += 1 }
}

@MainActor
struct WidgetTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    /// 20 Oct 2026, 9am UTC.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 9))!
    }

    private func task(_ title: String, hoursFromNow: Double, dog: String? = "Biscuit") -> UpcomingTask {
        UpcomingTask(title: title, dueDate: now.addingTimeInterval(hoursFromNow * 3600), dogName: dog)
    }

    // MARK: Snapshot rules

    @Test func snapshotSortsSoonestFirstWithOverdueAtTheTop() {
        let tasks = [task("Dinner", hoursFromNow: 9), task("Walk", hoursFromNow: 1), task("Brush", hoursFromNow: -2)]

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: tasks, now: now)

        #expect(snapshot.tasks.map(\.title) == ["Brush", "Walk", "Dinner"])
        #expect(snapshot.overdueCount(at: now) == 1)
    }

    @Test func snapshotDropsTasksBeyondTheSevenDayHorizon() {
        let tasks = [task("Soon", hoursFromNow: 24), task("Far away", hoursFromNow: 24 * 10)]

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: tasks, now: now)

        #expect(snapshot.tasks.map(\.title) == ["Soon"])
    }

    @Test func snapshotIsCappedToWhatFitsOnAWidget() {
        let tasks = (0..<20).map { task("Task \($0)", hoursFromNow: Double($0)) }

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: tasks, now: now)

        #expect(snapshot.tasks.count == BuildWidgetSnapshotUseCase.maxTasks)
        #expect(snapshot.tasks.first?.title == "Task 0")
    }

    // MARK: Status and labels

    @Test func taskStatusIsOverdueDueTodayOrUpcoming() {
        #expect(task("a", hoursFromNow: -1).status(at: now, calendar: calendar) == .overdue)
        #expect(task("b", hoursFromNow: 2).status(at: now, calendar: calendar) == .dueToday)
        #expect(task("c", hoursFromNow: 30).status(at: now, calendar: calendar) == .upcoming)
    }

    @Test func dueLabelNamesOverdueAndTomorrow() {
        #expect(task("a", hoursFromNow: -1).dueLabel(at: now, calendar: calendar) == "Overdue")
        #expect(task("b", hoursFromNow: 24).dueLabel(at: now, calendar: calendar) == "Tomorrow")
    }

    // MARK: Category

    @Test func snapshotSavedBeforeCategoriesStillDecodes() throws {
        let oldJSON = #"{"generatedAt":0,"tasks":[{"title":"Walk","dueDate":0,"dogName":"Biscuit"}]}"#

        let snapshot = try JSONDecoder().decode(WidgetSnapshot.self, from: Data(oldJSON.utf8))

        #expect(snapshot.tasks.first?.title == "Walk")
        #expect(snapshot.tasks.first?.category == nil)
    }

    @Test func categoryRoundTripsThroughTheSnapshot() throws {
        let original = WidgetSnapshot(
            generatedAt: now,
            tasks: [UpcomingTask(title: "Walk", dueDate: now, dogName: "Biscuit", category: "walk")]
        )

        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: JSONEncoder().encode(original))

        #expect(decoded.tasks.first?.category == "walk")
    }

    @Test func missedRepeatIsLeftOutOnceItsNextOccurrenceExists() throws {
        let container = try ModelContainer(
            for: RoutineTask.self, Dog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let missed = RoutineTask(title: "Dinner", dueDate: now.addingTimeInterval(-18 * 3600), category: .meal, recurrence: .daily)
        missed.hasNextOccurrence = true
        let next = RoutineTask(title: "Dinner", dueDate: now.addingTimeInterval(6 * 3600), category: .meal, recurrence: .daily)
        context.insert(missed)
        context.insert(next)
        try context.save()

        let tasks = try SwiftDataUpcomingTaskRepository(context: context).fetchIncompleteTasks()

        #expect(tasks.map(\.dueDate) == [next.dueDate])
        #expect(tasks.first?.category == "meal")
    }

    // MARK: Refreshing

    @Test func refreshSavesSnapshotAndReloadsWidget() throws {
        let repository = MockUpcomingTaskRepository()
        repository.tasks = [task("Walk", hoursFromNow: 1)]
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()

        try RefreshWidgetUseCase(tasks: repository, store: store, reloader: reloader).execute(now: now)

        #expect(store.snapshot.tasks.map(\.title) == ["Walk"])
        #expect(reloader.reloadCount == 1)
    }

    @Test func refreshDoesNothingWhenTheTasksHaveNotChanged() throws {
        let repository = MockUpcomingTaskRepository()
        repository.tasks = [task("Walk", hoursFromNow: 1)]
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()
        let useCase = RefreshWidgetUseCase(tasks: repository, store: store, reloader: reloader)

        try useCase.execute(now: now)
        try useCase.execute(now: now.addingTimeInterval(60))

        #expect(store.saveCount == 1)
        #expect(reloader.reloadCount == 1)
    }

    @Test func completingTheLastTaskClearsTheWidget() throws {
        let repository = MockUpcomingTaskRepository()
        repository.tasks = [task("Walk", hoursFromNow: 1)]
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()
        let useCase = RefreshWidgetUseCase(tasks: repository, store: store, reloader: reloader)
        try useCase.execute(now: now)

        repository.tasks = []
        try useCase.execute(now: now)

        #expect(store.snapshot.tasks.isEmpty)
        #expect(reloader.reloadCount == 2)
    }

    @Test func refreshMapsRepositoryFailureToCouldNotReadTasks() {
        let repository = MockUpcomingTaskRepository()
        repository.shouldFail = true
        let useCase = RefreshWidgetUseCase(
            tasks: repository, store: InMemoryWidgetSnapshotStore(), reloader: MockWidgetReloader()
        )

        #expect(throws: WidgetSyncError.couldNotReadTasks) {
            try useCase.execute(now: now)
        }
    }

    @Test func missingAppGroupIsReportedAndDoesNotReloadTheWidget() {
        let repository = MockUpcomingTaskRepository()
        repository.tasks = [task("Walk", hoursFromNow: 1)]
        let store = InMemoryWidgetSnapshotStore()
        store.error = .appGroupUnavailable
        let reloader = MockWidgetReloader()
        let useCase = RefreshWidgetUseCase(tasks: repository, store: store, reloader: reloader)

        #expect(throws: WidgetSyncError.appGroupUnavailable) {
            try useCase.execute(now: now)
        }
        #expect(reloader.reloadCount == 0)
    }
}
