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
    private let container: ModelContainer?
    private let repositories: PawprintRepositories?
    private let widgetSync: WidgetSyncService?
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
            let loadedContainer = try ModelContainer(for: schema)
            container = loadedContainer
            repositories = PawprintRepositories(container: loadedContainer)
            let sync = WidgetSyncService(container: loadedContainer)
            widgetSync = sync
            sync.start()
        } catch {
            // A persistent-store failure must not terminate the app with fatalError.
            container = nil
            repositories = nil
            widgetSync = nil
            NSLog("Pawprint persistent-store startup failed: %@", error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container, let repositories {
                    RootView()
                        .environment(repositories)
                        .modelContainer(container)
                } else {
                    ContentUnavailableView {
                        Label("Unable to open Pawprint", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("Your local care records could not be opened. Please restart the app. If the problem continues, contact support before reinstalling; reinstalling may erase local data.")
                    }
                    .accessibilityIdentifier("persistenceErrorScreen")
                }
            }
            .environment(\.font, PawprintTheme.font(.body))
            .preferredColorScheme((AppearanceSetting(rawValue: appearanceRaw) ?? .system).colorScheme)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { widgetSync?.applyPendingCompletions() }
            }
        }
    }
}
