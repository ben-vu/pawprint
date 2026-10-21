//
//  RoutineListView.swift
//  Routines feature (Sana)
//
//  Placeholder entry view. Replace the body, keep the name.
//

import SwiftUI
import SwiftData

struct RoutineListView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                Text("Routines")
                    .font(PawprintTheme.displayFont())
                    .foregroundStyle(PawprintTheme.accentDeep)
            }
            .navigationTitle("Routines")
        }
    }
}

#Preview {
    RoutineListView()
        .modelContainer(for: RoutineTask.self, inMemory: true)
}
