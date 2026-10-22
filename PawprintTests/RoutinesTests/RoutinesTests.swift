//
//  RoutinesTests.swift
//  PawprintTests
//
//  Created by Natalie Michael on 20/10/2026.
//
//  Pattern: a mock repository that stores items in an array, then tests
//  that drive the ViewModel or use case through the protocol only.
//

import Foundation
import Testing
@testable import Pawprint

@MainActor
final class MockRoutineRepository: RoutineRepository {
    var items: [RoutineTask] = []
    var shouldFail = false

    struct MockFailure: Error {}

    func fetchAll() throws -> [RoutineTask] {
        if shouldFail { throw MockFailure() }
        return items
    }

    func save(_ task: RoutineTask) throws {
        if shouldFail { throw MockFailure() }
        if !items.contains(where: { $0 === task }) { items.append(task) }   // saving an existing task updates it
    }

    func delete(_ task: RoutineTask) throws {
        if shouldFail { throw MockFailure() }
        items.removeAll { $0 === task }
    }
}

@MainActor
final class MockNotificationService: NotificationService {
    var scheduled: [String] = []
    var cancelled: [String] = []
    var allowsNotifications = true

    func requestAuthorization() async -> Bool { allowsNotifications }

    func scheduleReminder(for task: RoutineTask) {
        if task.remindMe { scheduled.append(task.reminderID) }
    }

    func cancelReminder(for task: RoutineTask) {
        cancelled.append(task.reminderID)
    }
}

/// Fixed calendar and dates so tests don't depend on the device's time zone or clock.
@MainActor
enum RoutineFixtures {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney")!
        return calendar
    }()

    static func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }
}

@MainActor
struct RoutinesTests {
    let calendar = RoutineFixtures.calendar
    func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date { RoutineFixtures.date(day, hour, minute) }

    // MARK: Loading

    @Test func savingThenLoadingReturnsTheItem() throws {
        let repository = MockRoutineRepository()
        try repository.save(RoutineTask(title: "Morning walk", dueDate: .now))

        let viewModel = RoutineViewModel(repository: repository, notifications: MockNotificationService())
        viewModel.load()

        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func repositoryFailureSurfacesAnErrorMessage() {
        let repository = MockRoutineRepository()
        repository.shouldFail = true

        let viewModel = RoutineViewModel(repository: repository, notifications: MockNotificationService())
        viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: Completing a task

    @Test func completingATaskMarksItDoneAndCancelsItsReminder() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let task = RoutineTask(title: "Flea tablet", dueDate: date(21, 9), remindMe: true)
        try repository.save(task)

        let next = try CompleteRoutineUseCase(repository: repository, notifications: notifications)
            .execute(task, now: date(21, 9, 30))

        #expect(task.isCompleted)
        #expect(task.completedAt == date(21, 9, 30))
        #expect(notifications.cancelled == [task.reminderID])
        #expect(next == nil)                     // one-off, nothing to repeat
        #expect(repository.items.count == 1)
    }

    @Test func completingATaskTwiceThrows() throws {
        let repository = MockRoutineRepository()
        let task = RoutineTask(title: "Walk", dueDate: date(21, 8), isCompleted: true)

        #expect(throws: RoutineError.alreadyCompleted) {
            try CompleteRoutineUseCase(repository: repository, notifications: MockNotificationService()).execute(task)
        }
    }

    @Test func completingADailyTaskCreatesTomorrowsTask() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let task = RoutineTask(title: "Morning walk", dueDate: date(21, 8), category: .walk, recurrence: .daily, remindMe: true)
        try repository.save(task)

        let useCase = CompleteRoutineUseCase(repository: repository, notifications: notifications, nextOccurrence: NextOccurrenceUseCase(calendar: calendar))
        let next = try #require(try useCase.execute(task, now: date(21, 8, 15)))

        #expect(next.dueDate == date(22, 8))
        #expect(next.title == "Morning walk")
        #expect(next.category == .walk)
        #expect(next.recurrence == .daily)
        #expect(!next.isCompleted)
        #expect(task.hasNextOccurrence)
        #expect(repository.items.count == 2)
        #expect(notifications.scheduled == [next.reminderID])
    }

    // MARK: Next occurrence

    @Test func dailyTaskRepeatsTheNextDayAtTheSameTime() {
        let useCase = NextOccurrenceUseCase(calendar: calendar)
        #expect(useCase.execute(after: date(21, 18, 30), recurrence: .daily, today: date(21, 19)) == date(22, 18, 30))
    }

    @Test func weeklyTaskRepeatsSevenDaysLater() {
        let useCase = NextOccurrenceUseCase(calendar: calendar)
        #expect(useCase.execute(after: date(21, 10), recurrence: .weekly, today: date(21, 11)) == date(28, 10))
    }

    @Test func oneOffTaskHasNoNextOccurrence() {
        let useCase = NextOccurrenceUseCase(calendar: calendar)
        #expect(useCase.execute(after: date(21, 10), recurrence: .once, today: date(21, 11)) == nil)
    }

    @Test func missedDaysAreSkippedSoTheNextOccurrenceIsToday() {
        // Due on the 15th, app not opened until the 21st: next walk is today, not a backlog.
        let useCase = NextOccurrenceUseCase(calendar: calendar)
        #expect(useCase.execute(after: date(15, 8), recurrence: .daily, today: date(21, 12)) == date(21, 8))
    }

    @Test func dailyTaskKeepsItsTimeAcrossDaylightSaving() {
        // Sydney clocks go forward at 2am on 4 October 2026.
        let useCase = NextOccurrenceUseCase(calendar: calendar)
        #expect(useCase.execute(after: date(3, 8), recurrence: .daily, today: date(3, 9)) == date(4, 8))
    }

    // MARK: Creating and deleting

    @Test func creatingARoutineTrimsTheTitleAndSchedulesAReminder() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()

        let task = try CreateRoutineUseCase(repository: repository, notifications: notifications)
            .execute(title: "  Dinner  ", category: .meal, dueDate: date(21, 18), recurrence: .daily, remindMe: true)

        #expect(task.title == "Dinner")
        #expect(repository.items.count == 1)
        #expect(notifications.scheduled == [task.reminderID])
    }

    @Test func creatingARoutineWithoutAReminderSchedulesNothing() throws {
        let notifications = MockNotificationService()
        _ = try CreateRoutineUseCase(repository: MockRoutineRepository(), notifications: notifications)
            .execute(title: "Dinner", category: .meal, dueDate: date(21, 18), recurrence: .once, remindMe: false)

        #expect(notifications.scheduled.isEmpty)
    }

    @Test func creatingARoutineWithABlankTitleThrows() {
        let repository = MockRoutineRepository()
        #expect(throws: RoutineError.emptyTitle) {
            try CreateRoutineUseCase(repository: repository, notifications: MockNotificationService())
                .execute(title: "   ", category: .walk, dueDate: .now, recurrence: .once, remindMe: false)
        }
        #expect(repository.items.isEmpty)
    }

    @Test func creatingARoutineWithAVeryLongTitleThrows() {
        let title = String(repeating: "a", count: CreateRoutineUseCase.maxTitleLength + 1)
        #expect(throws: RoutineError.titleTooLong) {
            try CreateRoutineUseCase(repository: MockRoutineRepository(), notifications: MockNotificationService())
                .execute(title: title, category: .walk, dueDate: .now, recurrence: .once, remindMe: false)
        }
    }

    @Test func deletingARoutineRemovesItAndCancelsItsReminder() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let task = RoutineTask(title: "Walk", dueDate: date(21, 8), remindMe: true)
        try repository.save(task)

        try DeleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)

        #expect(repository.items.isEmpty)
        #expect(notifications.cancelled == [task.reminderID])
    }

    // MARK: ViewModel sections

    @Test func loadingRollsAMissedDailyTaskForwardToToday() throws {
        let repository = MockRoutineRepository()
        let missed = RoutineTask(title: "Walk", dueDate: date(19, 8), recurrence: .daily)
        try repository.save(missed)

        let viewModel = RoutineViewModel(repository: repository, notifications: MockNotificationService(), calendar: calendar)
        viewModel.load(now: date(21, 10))

        #expect(viewModel.todays.map(\.dueDate) == [date(21, 8)])
        #expect(viewModel.overdue.isEmpty)        // the missed repeat is replaced, not nagged about
        #expect(repository.items.count == 2)

        viewModel.load(now: date(21, 10))         // loading again doesn't duplicate
        #expect(repository.items.count == 2)
    }

    @Test func tasksAreGroupedIntoOverdueTodayAndUpcoming() throws {
        let repository = MockRoutineRepository()
        let vet = RoutineTask(title: "Vet", dueDate: date(20, 15))
        let breakfast = RoutineTask(title: "Breakfast", dueDate: date(21, 7), isCompleted: true)
        let groom = RoutineTask(title: "Groom", dueDate: date(23, 10))
        for task in [groom, vet, breakfast] { try repository.save(task) }

        let viewModel = RoutineViewModel(repository: repository, notifications: MockNotificationService(), calendar: calendar)
        viewModel.load(now: date(21, 12))

        #expect(viewModel.overdue.map(\.title) == ["Vet"])
        #expect(viewModel.todays.map(\.title) == ["Breakfast"])
        #expect(viewModel.upcoming.map(\.title) == ["Groom"])
    }

    @Test func turningOnRemindersWithoutPermissionSwitchesItBackOff() async {
        let notifications = MockNotificationService()
        notifications.allowsNotifications = false
        let viewModel = AddRoutineViewModel(repository: MockRoutineRepository(), notifications: notifications, dog: nil)

        viewModel.remindMe = true
        await viewModel.reminderToggled()

        #expect(!viewModel.remindMe)
        #expect(viewModel.notificationsDenied)
    }

    @Test func newRoutineBelongsToTheDogFromTheDogRepository() {
        let repository = MockRoutineRepository()
        let dogs = MockDogRepository()
        let dog = Dog(name: "Rosie", breed: "Pug", ageYears: 2, weightKg: 8)
        dogs.items = [dog]
        let viewModel = AddRoutineViewModel(repository: repository, notifications: MockNotificationService(), dogs: dogs)
        viewModel.title = "Walk"

        #expect(viewModel.save())
        #expect(repository.items.first?.dog === dog)
    }
    // MARK: Unticking a task

    @Test func untickingATaskMarksItNotDoneAndRestoresItsReminder() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let task = RoutineTask(title: "Vet", dueDate: .now.addingTimeInterval(3600), isCompleted: true, remindMe: true)
        task.completedAt = .now
        try repository.save(task)

        try UncompleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)

        #expect(!task.isCompleted)
        #expect(task.completedAt == nil)
        #expect(notifications.scheduled == [task.reminderID])
    }

    @Test func untickingADailyTaskRemovesTheNextOneItCreated() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let task = RoutineTask(title: "Walk", dueDate: date(21, 8), recurrence: .daily, remindMe: true)
        try repository.save(task)
        let next = try #require(try CompleteRoutineUseCase(repository: repository, notifications: notifications, nextOccurrence: NextOccurrenceUseCase(calendar: calendar))
            .execute(task, now: date(21, 8, 5)))

        try UncompleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)

        #expect(repository.items.map(\.reminderID) == [task.reminderID])
        #expect(notifications.cancelled.contains(next.reminderID))
        #expect(!task.hasNextOccurrence)
        #expect(task.nextOccurrenceID == nil)
    }

    @Test func untickingKeepsTheNextTaskIfItIsAlreadyDone() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let useCase = CompleteRoutineUseCase(repository: repository, notifications: notifications, nextOccurrence: NextOccurrenceUseCase(calendar: calendar))
        let task = RoutineTask(title: "Walk", dueDate: date(21, 8), recurrence: .daily)
        try repository.save(task)
        let next = try #require(try useCase.execute(task, now: date(21, 8)))
        try useCase.execute(next, now: date(22, 8))

        try UncompleteRoutineUseCase(repository: repository, notifications: notifications).execute(task)

        #expect(repository.items.contains { $0 === next })
        #expect(task.hasNextOccurrence)
    }

    @Test func untickingATaskThatIsNotDoneThrows() {
        let task = RoutineTask(title: "Walk", dueDate: .now)
        #expect(throws: RoutineError.notCompleted) {
            try UncompleteRoutineUseCase(repository: MockRoutineRepository(), notifications: MockNotificationService()).execute(task)
        }
    }

    // MARK: Editing a task

    @Test func editingARoutineUpdatesItAndMovesItsReminder() throws {
        let repository = MockRoutineRepository()
        let notifications = MockNotificationService()
        let task = RoutineTask(title: "Walk", dueDate: date(21, 8), category: .walk, remindMe: true)
        try repository.save(task)

        try UpdateRoutineUseCase(repository: repository, notifications: notifications)
            .execute(task, title: " Evening walk ", category: .play, dueDate: date(21, 18), recurrence: .weekly, remindMe: true)

        #expect(task.title == "Evening walk")
        #expect(task.category == .play)
        #expect(task.dueDate == date(21, 18))
        #expect(task.recurrence == .weekly)
        #expect(repository.items.count == 1)
        #expect(notifications.cancelled == [task.reminderID])
        #expect(notifications.scheduled == [task.reminderID])
    }

    @Test func editingARoutineToABlankTitleThrowsAndKeepsTheOldTitle() {
        let task = RoutineTask(title: "Walk", dueDate: .now)
        #expect(throws: RoutineError.emptyTitle) {
            try UpdateRoutineUseCase(repository: MockRoutineRepository(), notifications: MockNotificationService())
                .execute(task, title: "  ", category: .walk, dueDate: .now, recurrence: .once, remindMe: false)
        }
        #expect(task.title == "Walk")
    }

    @Test func editFormStartsFilledInWithTheTask() {
        let task = RoutineTask(title: "Dinner", dueDate: date(21, 18), category: .meal, recurrence: .weekly, remindMe: true)
        let viewModel = AddRoutineViewModel(repository: MockRoutineRepository(), notifications: MockNotificationService(), dog: nil, editing: task)

        #expect(viewModel.isEditing)
        #expect(viewModel.title == "Dinner")
        #expect(viewModel.category == .meal)
        #expect(viewModel.dueDate == date(21, 18))
        #expect(viewModel.recurrence == .weekly)
        #expect(viewModel.remindMe)
    }
}
