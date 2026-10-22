//
//  WidgetTests.swift
//  PawprintTests
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Covers the rules that decide what the widgets show (routines, health
//  follow-ups and the Learn tip), using a mock data repository, an
//  in-memory snapshot store and a mock reloader.
//

import Foundation
import Testing
import SwiftData
@testable import Pawprint

@MainActor
final class MockWidgetDataRepository: WidgetDataRepository {
    var tasks: [UpcomingTask] = []
    var healthItems: [HealthDueItem] = []
    var tips: [LearnTip] = []
    var dogCount = 1
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchIncompleteTasks() throws -> [UpcomingTask] {
        if shouldFail { throw MockFailure() }
        return tasks
    }

    func fetchHealthRecords() throws -> [HealthDueItem] {
        if shouldFail { throw MockFailure() }
        return healthItems
    }

    func fetchTips() throws -> [LearnTip] {
        if shouldFail { throw MockFailure() }
        return tips
    }

    func fetchDogCount() throws -> Int {
        if shouldFail { throw MockFailure() }
        return dogCount
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

    private func hours(_ value: Double) -> Date { now.addingTimeInterval(value * 3600) }
    private func days(_ value: Double) -> Date { now.addingTimeInterval(value * 86400) }

    private func task(_ title: String, hoursFromNow: Double, dog: String? = "Biscuit") -> UpcomingTask {
        UpcomingTask(title: title, dueDate: hours(hoursFromNow), dogName: dog)
    }

    private func healthItem(_ title: String, given: Date, due: Date?, dogID: UUID? = nil) -> HealthDueItem {
        HealthDueItem(title: title, recordDate: given, nextDueDate: due, dogName: "Biscuit", dogID: dogID)
    }

    private func guide(_ id: String, order: Int) -> LearnTip {
        LearnTip(contentID: id, title: id, category: .health, summary: "s", body: "b", sortOrder: order)
    }

    }

    private func healthItem(_ title: String, given: Date, due: Date?, dogID: UUID? = nil) -> HealthDueItem {
        HealthDueItem(title: title, recordDate: given, nextDueDate: due, dogName: "Biscuit", dogID: dogID)
    }

    private func guide(_ id: String, order: Int) -> LearnTip {
        LearnTip(contentID: id, title: id, category: .health, summary: "s", body: "b", sortOrder: order)
    }

    // MARK: Routine rules

    @Test func snapshotSortsSoonestFirstWithOverdueAtTheTop() {
        let tasks = [task("Dinner", hoursFromNow: 9), task("Walk", hoursFromNow: 1), task("Brush", hoursFromNow: -2)]

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: tasks, now: now)

        #expect(snapshot.tasks.map(\.title) == ["Brush", "Walk", "Dinner"])
        #expect(snapshot.overdueCount(at: now) == 1)
    }

    @Test func routinesBeyondTheSevenDayHorizonAreDropped() {
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
            for: RoutineTask.self, Dog.self, HealthRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let missed = RoutineTask(title: "Dinner", dueDate: hours(-18), category: .meal, recurrence: .daily)
        missed.hasNextOccurrence = true
        let next = RoutineTask(title: "Dinner", dueDate: hours(6), category: .meal, recurrence: .daily)
        context.insert(missed)
        context.insert(next)
        try context.save()

        let tasks = try SwiftDataWidgetDataRepository(context: context).fetchIncompleteTasks()

        #expect(tasks.map(\.dueDate) == [next.dueDate])
        #expect(tasks.first?.category == "meal")
    }

    // MARK: Health rules

    @Test func healthFollowUpsAppearAlongsideRoutinesWithinThirtyDays() {
        let items = [
            healthItem("Rabies vaccine", given: days(-300), due: days(5)),
            healthItem("Worming", given: days(-60), due: days(60))
        ]

        let snapshot = BuildWidgetSnapshotUseCase().execute(
            tasks: [task("Walk", hoursFromNow: 2)], healthItems: items, now: now
        )

        #expect(snapshot.tasks.map(\.title) == ["Walk", "Rabies vaccine"])
        #expect(snapshot.tasks.last?.kind == .health)
    }

    @Test func overdueHealthFollowUpsAreIncluded() {
        let items = [healthItem("Flea treatment", given: days(-40), due: days(-10))]

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: [], healthItems: items, now: now)

        #expect(snapshot.tasks.count == 1)
        #expect(snapshot.overdueCount(at: now) == 1)
    }

    @Test func aNewerRecordWithTheSameNameReplacesTheOldFollowUp() {
        let dogID = UUID()
        let items = [
            healthItem("Rabies vaccine", given: days(-365), due: days(-5), dogID: dogID),
            healthItem("rabies vaccine ", given: days(-4), due: days(361), dogID: dogID)
        ]

        let outstanding = BuildWidgetSnapshotUseCase.outstandingHealthItems(items)

        #expect(outstanding.count == 1)
        #expect(outstanding.first?.recordDate == days(-4))
    }

    @Test func aRenewalForAnotherDogDoesNotCancelThisDogsFollowUp() {
        let items = [
            healthItem("Rabies vaccine", given: days(-365), due: days(-5), dogID: UUID()),
            healthItem("Rabies vaccine", given: days(-4), due: days(361), dogID: UUID())
        ]

        #expect(BuildWidgetSnapshotUseCase.outstandingHealthItems(items).count == 2)
    }

    // MARK: Learn tip

    @Test func snapshotCarriesAWeekOfDailyTips() {
        let tips = (0..<10).map { guide("guide-\($0)", order: $0) }

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: [], tips: tips, now: now)

        #expect(snapshot.tips.count == 7)
        #expect(Set(snapshot.tips.map(\.contentID)).count == 7)
    }

    @Test func vetGuideBecomesTodaysTipWhenAHealthFollowUpIsDueThisWeek() {
        let tips = [guide("guide-a", order: 0), guide(TipOfTheDayUseCase.vetGuideID, order: 1), guide("guide-c", order: 2)]
        let items = [healthItem("Rabies vaccine", given: days(-300), due: days(3))]

        let snapshot = BuildWidgetSnapshotUseCase().execute(tasks: [], healthItems: items, tips: tips, now: now)

        #expect(snapshot.tip(on: now, calendar: calendar)?.contentID == TipOfTheDayUseCase.vetGuideID)
    }

    @Test func tipsRotateOnNormalDaysAndAreEmptyWithNoGuides() {
        let tips = (0..<5).map { guide("guide-\($0)", order: $0) }
        let useCase = TipOfTheDayUseCase(calendar: calendar)

        let plan = useCase.execute(tips: tips, from: now, days: 3)

        #expect(plan.count == 3)
        #expect(plan[0].contentID != plan[1].contentID)
        #expect(useCase.execute(tips: [], from: now).isEmpty)
    }

    // MARK: Status, labels and links

    @Test func taskStatusIsOverdueDueTodayOrUpcoming() {
        #expect(task("a", hoursFromNow: -1).status(at: now, calendar: calendar) == .overdue)
        #expect(task("b", hoursFromNow: 2).status(at: now, calendar: calendar) == .dueToday)
        #expect(task("c", hoursFromNow: 30).status(at: now, calendar: calendar) == .upcoming)
    }

    @Test func dueLabelNamesOverdueAndTomorrow() {
        #expect(task("a", hoursFromNow: -1).dueLabel(at: now, calendar: calendar) == "Overdue")
        #expect(task("b", hoursFromNow: 24).dueLabel(at: now, calendar: calendar) == "Tomorrow")
    }

    @Test func deepLinksRoundTripThroughAURL() {
        let links: [PawprintDeepLink] = [.home, .routines, .health, .learn(tipID: nil), .learn(tipID: "fleas-ticks-and-worms")]

        for link in links {
            #expect(PawprintDeepLink(url: link.url) == link)
        }
        #expect(PawprintDeepLink(url: URL(string: "https://example.com/health")!) == nil)
        #expect(PawprintDeepLink(url: URL(string: "pawprint://unknown")!) == nil)
    }

    @Test func tappingARowOpensItsTab() {
        #expect(task("Walk", hoursFromNow: 1).deepLink == .routines)
        #expect(UpcomingTask(title: "Vaccine", dueDate: now, kind: .health).deepLink == .health)
    }

    // MARK: Refreshing

    private func makeUseCase(
        _ data: MockWidgetDataRepository,
        _ store: InMemoryWidgetSnapshotStore,
        _ reloader: MockWidgetReloader
    ) -> RefreshWidgetUseCase {
        RefreshWidgetUseCase(data: data, store: store, reloader: reloader)
    }

    @Test func refreshSavesSnapshotAndReloadsWidgets() throws {
        let data = MockWidgetDataRepository()
        data.tasks = [task("Walk", hoursFromNow: 1)]
        data.dogCount = 2
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()

        try makeUseCase(data, store, reloader).execute(now: now)

        #expect(store.snapshot.tasks.map(\.title) == ["Walk"])
        #expect(store.snapshot.showsDogNames)
        #expect(reloader.reloadCount == 1)
    }

    @Test func refreshDoesNothingWhenNothingVisibleHasChanged() throws {
        let data = MockWidgetDataRepository()
        data.tasks = [task("Walk", hoursFromNow: 1)]
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()
        let useCase = makeUseCase(data, store, reloader)

        try useCase.execute(now: now)
        try useCase.execute(now: now.addingTimeInterval(60))

        #expect(store.saveCount == 1)
        #expect(reloader.reloadCount == 1)
    }

    @Test func completingTheLastTaskClearsTheWidget() throws {
        let data = MockWidgetDataRepository()
        data.tasks = [task("Walk", hoursFromNow: 1)]
    @Test func addingAHealthRecordChangesTheWidget() throws {
        let data = MockWidgetDataRepository()
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()
        let useCase = makeUseCase(data, store, reloader)
        try useCase.execute(now: now)

        data.tasks = []
        data.healthItems = [healthItem("Rabies vaccine", given: days(-300), due: days(3))]
        try useCase.execute(now: now)

        #expect(store.snapshot.tasks.first?.kind == .health)
        #expect(reloader.reloadCount == 2)
    }

    @Test func addingAHealthRecordChangesTheWidget() throws {
        let data = MockWidgetDataRepository()
        let store = InMemoryWidgetSnapshotStore()
        let reloader = MockWidgetReloader()
        let useCase = makeUseCase(data, store, reloader)
        try useCase.execute(now: now)

        data.healthItems = [healthItem("Rabies vaccine", given: days(-300), due: days(3))]
        try useCase.execute(now: now)

        #expect(store.snapshot.tasks.first?.kind == .health)
        #expect(reloader.reloadCount == 2)
    }

    @Test func refreshMapsRepositoryFailureToCouldNotReadTasks() {
        let data = MockWidgetDataRepository()
        data.shouldFail = true
        let useCase = makeUseCase(data, InMemoryWidgetSnapshotStore(), MockWidgetReloader())

        #expect(throws: WidgetSyncError.couldNotReadTasks) {
            try useCase.execute(now: now)
        }
    }

    @Test func missingAppGroupIsReportedAndDoesNotReloadTheWidget() {
        let data = MockWidgetDataRepository()
        data.tasks = [task("Walk", hoursFromNow: 1)]
        let store = InMemoryWidgetSnapshotStore()
        store.error = .appGroupUnavailable
        let reloader = MockWidgetReloader()

        #expect(throws: WidgetSyncError.appGroupUnavailable) {
            try makeUseCase(data, store, reloader).execute(now: now)
        }
        #expect(reloader.reloadCount == 0)
    }
}
