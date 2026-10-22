//
//  AddDogView.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Sheet for adding another dog. The new dog becomes the active one.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddDogView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var viewModel: AddDogViewModel?
    @State private var photoItem: PhotosPickerItem?
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
            .navigationTitle("Add another dog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        if let dog = viewModel?.save() {
                            selectedDogID = dog.id.uuidString
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
        }
        .task {
            if viewModel == nil {
                viewModel = AddDogViewModel(repository: SwiftDataDogRepository(context: context))
            }
        }
        .sensoryFeedback(.success, trigger: saveFeedback)
        .tint(PawprintTheme.accent)
    }

    private func form(_ vm: AddDogViewModel) -> some View {
        @Bindable var form = vm
        let currentPhoto = vm.photoData
        return ScrollView {
            VStack(spacing: 18) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    PhotoPickerLabel(photoData: currentPhoto, size: 120, title: "Add photo")
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
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    AddDogView()
        .modelContainer(for: Dog.self, inMemory: true)
}
