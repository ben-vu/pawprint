//
//  CompleteRoutineIntent.swift
//  PawprintWidget
//
//  What happens when someone taps the circle next to a task in the widget.
//
//  The widget never opens the app's database, so this does two small things
//  in the App Group: it queues "this task was done" for the app to apply
//  (see ApplyWidgetCompletionsUseCase) and it removes the task from the
//  saved snapshot so the widget updates straight away.
//

import AppIntents
import WidgetKit

nonisolated struct CompleteRoutineIntent: AppIntent {
    static let title: LocalizedStringResource = "Mark routine as done"
    static let description = IntentDescription("Ticks a routine off from the Pawprint widget.")
    static let isDiscoverable = false   // only meant for the widget's buttons, not Shortcuts

    @Parameter(title: "Task")
    var taskID: String

    init() {}

    init(taskID: String) {
        self.taskID = taskID
    }

    func perform() async throws -> some IntentResult {
        try AppGroupPendingCompletionStore().add(PendingCompletion(taskID: taskID, completedAt: .now))

        let store = AppGroupWidgetSnapshotStore()
        try? store.save(store.load().removing(taskIDs: [taskID]))

        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConfig.widgetKind)
        return .result()
    }
}
