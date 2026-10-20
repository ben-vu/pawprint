//
//  HomeView.swift
//  Dashboard feature (Natalie)
//
//  Placeholder entry view. Replace the body, keep the name so the tab bar
//  still finds it.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                Text("Home")
                    .font(PawprintTheme.displayFont())
                    .foregroundStyle(PawprintTheme.accentDeep)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Dog.self, inMemory: true)
}
