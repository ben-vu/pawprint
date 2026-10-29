//
//  ShareDogView.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  "Share with a sitter" sheet. The person picks which parts of the dog's
//  care sheet to include, checks the preview, then sends it with the
//  system share sheet (Messages, Mail, AirDrop and so on). Nothing leaves
//  the phone until they tap Share.
//

import SwiftUI

struct ShareDogView: View {
    let dog: Dog
    /// Called when the person taps "Add care details", just before this sheet closes.
    var onEditDetails: () -> Void = {}

    @Environment(PawprintRepositories.self) private var repositories
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ShareDogViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    content(viewModel)
                }
            }
            .navigationTitle("Share with a sitter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ShareDogViewModel(
                    dog: dog,
                    routines: repositories.routines,
                    health: repositories.health
                )
            }
            viewModel?.load()
        }
        .tint(PawprintTheme.accent)
    }

    private func content(_ vm: ShareDogViewModel) -> some View {
        @Bindable var form = vm
        return ScrollView {
            VStack(spacing: 18) {
                intro(vm)

                if !vm.hasCareDetails {
                    missingDetailsCard
                }

                PawprintCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What to include")
                            .font(PawprintTheme.font(.headline, weight: .semibold))
                            .foregroundStyle(PawprintTheme.textPrimary)
                        optionToggle("Your contact details", isOn: $form.options.includeOwnerContact)
                        optionToggle("Vet and microchip", isOn: $form.options.includeVet)
                        optionToggle("Feeding", isOn: $form.options.includeFeeding)
                        optionToggle("Medical notes", isOn: $form.options.includeMedical)
                        optionToggle("Behaviour and house rules", isOn: $form.options.includeBehaviour)
                        optionToggle("Daily routine", isOn: $form.options.includeRoutine)
                        optionToggle("Vaccines and treatments", isOn: $form.options.includeHealthHistory)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("PREVIEW")
                        .font(PawprintTheme.font(.caption, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(PawprintTheme.textSecondary)
                        .padding(.horizontal, 4)
                    PawprintCard {
                        Text(vm.summary)
                            .font(PawprintTheme.font(.footnote))
                            .foregroundStyle(PawprintTheme.textPrimary)
                            .textSelection(.enabled)
                    }
                }

                if let error = vm.errorMessage {
                    Label(error, systemImage: "exclamationmark.circle.fill")
                        .font(PawprintTheme.font(.footnote, weight: .semibold))
                        .foregroundStyle(PawprintTheme.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Error: \(error)")
                }

                ShareLink(item: vm.summary, subject: Text(vm.subject)) {
                    Label("Share care sheet", systemImage: "square.and.arrow.up")
                        .font(PawprintTheme.font(.headline, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .background(PawprintTheme.accentDeep, in: Capsule())
                        .foregroundStyle(PawprintTheme.onAccent)
                }

                Text("The sheet is sent as plain text. Phone numbers and medical notes can be read by anyone who receives it, so share it only with people you trust.")
                    .font(PawprintTheme.font(.caption))
                    .foregroundStyle(PawprintTheme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
        }
    }

    private func intro(_ vm: ShareDogViewModel) -> some View {
        PawprintCard {
            HStack(spacing: 14) {
                DogAvatarView(photoData: vm.dog.photoData, size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Looking after \(vm.dog.name)?")
                        .font(PawprintTheme.font(.headline, weight: .semibold))
                        .foregroundStyle(PawprintTheme.textPrimary)
                    Text("Send a sitter everything they need to know. You choose what goes in.")
                        .font(PawprintTheme.font(.subheadline))
                        .foregroundStyle(PawprintTheme.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var missingDetailsCard: some View {
        PawprintCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("No care details yet")
                    .font(PawprintTheme.font(.headline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.textPrimary)
                Text("Add your phone number, the vet and feeding or medical notes so the sheet is actually useful.")
                    .font(PawprintTheme.font(.subheadline))
                    .foregroundStyle(PawprintTheme.textSecondary)
                Button {
                    onEditDetails()
                    dismiss()
                } label: {
                    Text("Add care details")
                        .font(PawprintTheme.font(.subheadline, weight: .semibold))
                        .frame(minHeight: 44)
                }
                .foregroundStyle(PawprintTheme.accent)
            }
        }
    }

    private func optionToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(PawprintTheme.font(.body))
                .foregroundStyle(PawprintTheme.textPrimary)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    ShareDogView(dog: Dog(name: "Bella", breed: "Border Collie", ageYears: 3, weightKg: 18.5))
        .environment(PawprintRepositories.preview())
}
