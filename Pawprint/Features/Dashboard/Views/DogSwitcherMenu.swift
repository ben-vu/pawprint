//
//  DogSwitcherMenu.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  The dog's photo in the Home tab's navigation bar, the one place to switch
//  dog. Tap it to switch dog, edit the current profile, share the dog's care
//  sheet with a sitter or add another dog. The other tabs follow the choice.
//

import SwiftUI
import SwiftData

struct DogSwitcherMenu: View {
    @Environment(\.modelContext) private var context
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var viewModel: DogSwitcherViewModel?
    @State private var showAddDog = false
    @State private var profileDog: Dog?
    @State private var shareDog: Dog?
    @State private var editAfterShare = false

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
                        Button("Share with a sitter", systemImage: "square.and.arrow.up") { shareDog = active }
                    }
                    Button("Add another dog", systemImage: "plus") { showAddDog = true }
                }
            }
        } label: {
            DogAvatarView(photoData: viewModel?.activeDog?.photoData, size: 44)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)   // no glass bubble, the photo is the button
        .accessibilityLabel("Dog profile")
        .accessibilityValue(viewModel?.activeDog?.name ?? "")
        .accessibilityHint("Switch dog, edit the profile, share with a sitter or add another dog")
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
        .sheet(item: $shareDog, onDismiss: {
            // "Add care details" closes the share sheet first, then opens the profile.
            if editAfterShare {
                editAfterShare = false
                profileDog = viewModel?.activeDog
            }
        }) { dog in
            ShareDogView(dog: dog, onEditDetails: { editAfterShare = true })
        }
    }
}
