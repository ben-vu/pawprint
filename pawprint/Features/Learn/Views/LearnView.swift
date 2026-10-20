//
//  LearnView.swift
//  Learn feature (Ben)
//
//  Placeholder entry view. Replace the body, keep the name.
//  The widget lives in its own target, add it with File > New > Target.
//

import SwiftUI
import SwiftData

struct LearnView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                Text("Learn")
                    .font(PawprintTheme.displayFont())
                    .foregroundStyle(PawprintTheme.accentDeep)
            }
            .navigationTitle("Learn")
        }
    }
}

#Preview {
    LearnView()
        .modelContainer(for: LearnTip.self, inMemory: true)
}
