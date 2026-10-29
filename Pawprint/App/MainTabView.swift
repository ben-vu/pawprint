//
//  MainTabView.swift
//  Pawprint
//
//  Created by Natalie Michael on 20/10/2026.
//
//  Root navigation. One tab per feature, each pointing at that feature's
//  entry view. Also receives links from the Home Screen widgets and passes
//  them to the AppRouter.
//

import SwiftUI

struct MainTabView: View {
    @Environment(PawprintRepositories.self) private var repositories
    @State private var dogs: [Dog] = []
    @State private var loadError: String?
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var router = AppRouter()

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Routines", systemImage: "checklist", value: AppTab.routines) {
                RoutineListView()
            }
            Tab("Health", systemImage: "cross.case.fill", value: AppTab.health) {
                if let dog = ActiveDogUseCase().activeDog(in: dogs, selectedID: UUID(uuidString: selectedDogID)) {
                    NavigationStack {
                        HealthView(dog: dog)
                            .id(dog.id)
                    }
                } else {
                    ContentUnavailableView(
                        "No dog yet",
                        systemImage: "pawprint",
                        description: Text("Add a dog from the Home tab to start a health record.")
                    )
                }
            }
            Tab("Learn", systemImage: "book.fill", value: AppTab.learn) {
                LearnView()
            }
        }
        .tint(PawprintTheme.accent)
        .environment(router)
        .onOpenURL { router.handle(url: $0) }
        .task { reloadDogs() }
        .onChange(of: selectedDogID) { reloadDogs() }
        .onChange(of: router.selectedTab) { reloadDogs() }
        .onReceive(NotificationCenter.default.publisher(for: .pawprintDogsDidChange)) { _ in reloadDogs() }
        .alert("Unable to load dogs", isPresented: Binding(get: { loadError != nil }, set: { if !$0 { loadError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(loadError ?? "") }
    }
    private func reloadDogs() {
        do {
            dogs = try repositories.dogs.fetchAll()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    MainTabView().environment(PawprintRepositories.preview())
}
