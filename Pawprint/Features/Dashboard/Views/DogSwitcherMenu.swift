//
//  DogSwitcherMenu.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  The dog's photo in the navigation bar. Tap it to switch dog, edit the
//  current profile or add another dog.
//

import SwiftUI
import SwiftData

struct DogSwitcherMenu: View {
    @Environment(\.modelContext) private var context
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var viewModel: DogSwitcherViewModel?
    @State private var showAddDog = false
    @State private var profileDog: Dog?

    var body: some View {
        Menu {
            if let viewModel {
                Section("Your dogs") {
                    ForEach(viewModel.dogs) { dog in
                        Button {
                            viewModel.select(dog)
                        } label: {
                            if dog.id == viewModel.activeDog?.id {
                                Label(dog.name, systemImage: "checkmark")
                            } else {
                                Text(dog.name)
                            }
                        }
                    }
                }
                Section {
                    if let active = viewModel.activeDog {
                        Button("Edit profile", systemImage: "pencil") { profileDog = active }
                    }
                    Button("Add another dog", systemImage: "plus") { showAddDog = true }
                }
            }
        } label: {
            DogAvatarView(photoData: viewModel?.activeDog?.photoData, size: 34)
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel("Dog profile")
        .accessibilityValue(viewModel?.activeDog?.name ?? "")
        .accessibilityHint("Switch dog, edit the profile or add another dog")
        .task {
            if viewModel == nil {
                viewModel = DogSwitcherViewModel(repository: SwiftDataDogRepository(context: context))
            }
            viewModel?.load()
        }
        .onChange(of: selectedDogID) { viewModel?.load() }
        .sheet(isPresented: $showAddDog, onDismiss: { viewModel?.load() }) {
            AddDogView()
        }
        .sheet(item: $profileDog, onDismiss: { viewModel?.load() }) { dog in
            DogProfileView(dog: dog)
        }
    }
}
