//
//  pawprintApp.swift
//  pawprint
//
//  App entry point. Owns the SwiftData container shared by every feature.
//  Add new @Model types to the schema list below. This is the only shared
//  file each feature owner may need to touch.
//

import SwiftUI
import SwiftData

@main
struct pawprintApp: App {
    let container: ModelContainer

    init() {
        PawprintFonts.registerAll()       // load Nunito before any view draws
        PawprintFonts.applyAppearance()   // nav titles and tab labels use it too

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
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.font, PawprintTheme.font(.body))   // default for any Text without its own font
        }
        .modelContainer(container)
    }
}
