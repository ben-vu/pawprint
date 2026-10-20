//
//  MainTabView.swift
//  pawprint
//
//  Root navigation. One tab per feature, each pointing at that feature's
//  entry view. Feature owners replace the entry view in their own folder,
//  not here.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Routines", systemImage: "checklist") {
                RoutineListView()
            }
            Tab("Health", systemImage: "cross.case.fill") {
                HealthView()
            }
            Tab("Learn", systemImage: "book.fill") {
                LearnView()
            }
        }
        .tint(PawprintTheme.accent)
    }
}

#Preview {
    MainTabView()
}
