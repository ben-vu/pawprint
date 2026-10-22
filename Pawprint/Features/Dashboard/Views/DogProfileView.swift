//
//  DogProfileView.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  View and edit the dog. Deleting resets onboarding so the app starts
//  fresh next time.
//

import SwiftUI
import SwiftData
import PhotosUI

struct DogProfileView: View {
    let dog: Dog

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var viewModel: DogProfileViewModel?
    @State private var photoItem: PhotosPickerItem?
    @State private var confirmDelete = false
    @State private var saveFeedback = 0
    @FocusState private var focusedField: Field?

    enum Field { case name, breed, weight }

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    form(viewModel)
                }
            }
            .navigationTitle("Dog profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        if viewModel?.save() == true {
                            saveFeedback += 1
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .confirmationDialog("Remove \(dog.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Remove profile", role: .destructive) {
                    if viewModel?.delete() == true {
                        selectedDogID = ""
                        if viewModel?.hasNoDogsLeft == true { hasCompletedOnboarding = false }
                        dismiss()
                    }
                }
            } message: {
                Text("This deletes the profile, and its routines and health records, from this phone.")
            }
        }
        .task {
            if viewModel == nil {
                viewModel = DogProfileViewModel(dog: dog, repository: SwiftDataDogRepository(context: context))
            }
        }
        .sensoryFeedback(.success, trigger: saveFeedback)
        .tint(PawprintTheme.accent)
    }

    private func form(_ vm: DogProfileViewModel) -> some View {
        @Bindable var form = vm
        let currentPhoto = vm.photoData
        return ScrollView {
            VStack(spacing: 18) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    PhotoPickerLabel(photoData: currentPhoto, size: 120, title: "Change photo")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dog photo")
                .onChange(of: photoItem) { _, item in
                    Task {
                        if let item, let data = try? await item.loadTransferable(type: Data.self) {
                            vm.photoData = data
                        }
                    }
                }

                PawprintCard {
                    VStack(spacing: 16) {
                        DogFormField(label: "Name", placeholder: "Bella", text: $form.name, focus: $focusedField, field: .name)
                        DogFormField(label: "Breed", placeholder: "Border Collie", text: $form.breed, focus: $focusedField, field: .breed)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(PawprintTheme.font(.caption, weight: .bold))
                                .foregroundStyle(PawprintTheme.textSecondary)
                                .textCase(.uppercase)
                            Stepper(value: $form.ageYears, in: 0...30) {
                                Text(vm.ageYears == 0 ? "Under 1 year" : "\(vm.ageYears) yr\(vm.ageYears == 1 ? "" : "s")")
                                    .foregroundStyle(PawprintTheme.textPrimary)
                            }
                            .frame(minHeight: 48)
                        }
                        DogFormField(label: "Weight (kg)", placeholder: "18.5", text: $form.weightText, keyboard: .decimalPad, focus: $focusedField, field: .weight)
                    }
                }

                if let error = vm.errorMessage {
                    Label(error, systemImage: "exclamationmark.circle.fill")
                        .font(PawprintTheme.font(.footnote, weight: .semibold))
                        .foregroundStyle(PawprintTheme.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Error: \(error)")
                }

                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Text("Remove profile")
                        .font(PawprintTheme.font(.subheadline, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                }
                .foregroundStyle(PawprintTheme.danger)
                .padding(.top, 8)
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    DogProfileView(dog: Dog(name: "Bella", breed: "Border Collie", ageYears: 3, weightKg: 18.5))
        .modelContainer(for: Dog.self, inMemory: true)
}
