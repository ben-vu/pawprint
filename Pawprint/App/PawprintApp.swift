//
//  PawprintApp.swift
//  Pawprint
//
//  Created by Natalie Michael on 20/10/2026.
//
//  App entry point. Owns the SwiftData container shared by every feature.
//  Add new @Model types to the schema list below. This is the only shared
//  file each feature owner may need to touch.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PawprintApp: App {
    let container: ModelContainer
    private let widgetSync: WidgetSyncService
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppearanceSetting.storageKey) private var appearanceRaw = AppearanceSetting.system.rawValue

    init() {
        PawprintFonts.registerAll()       // load Nunito before any view draws
        PawprintFonts.applyAppearance()   // nav titles and tab labels use it too
        UNUserNotificationCenter.current().delegate = UserNotificationService.shared   // routine reminders show while the app is open

        let schema = Schema([
            Dog.self,           // Dashboard (Natalie)
            RoutineTask.self,   // Routines (Sana)
            HealthRecord.self,  // Health (Alik)
            LearnTip.self       // Learn (Ben)
        ])
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create the SwiftData container: \(error)")
        }
        widgetSync = WidgetSyncService(container: container)
        widgetSync.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.font, PawprintTheme.font(.body))   // default for any Text without its own font
                .preferredColorScheme((AppearanceSetting(rawValue: appearanceRaw) ?? .system).colorScheme)
                .onChange(of: scenePhase) { _, phase in
                    // Tasks ticked off in the widget while the app was closed.
                    if phase == .active { widgetSync.applyPendingCompletions() }
                }
        }
        .modelContainer(container)
    }
}
