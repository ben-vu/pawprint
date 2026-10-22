//
//  OnboardingView.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Three steps: welcome, dog details, done. The details step saves through
//  the view model, which uses CreateDogUseCase for validation.
//

import SwiftUI
import SwiftData
import PhotosUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.modelContext) private var context
    @State private var viewModel: OnboardingViewModel?
    @State private var photoItem: PhotosPickerItem?
    @State private var saveFeedback = 0
    @FocusState private var focusedField: Field?

    enum Field { case name, breed, weight }

    var body: some View {
        ZStack {
            PawprintTheme.background.ignoresSafeArea()
            if let viewModel {
                content(viewModel)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = OnboardingViewModel(repository: SwiftDataDogRepository(context: context))
            }
        }
        .sensoryFeedback(.success, trigger: saveFeedback)
    }

    @ViewBuilder
    private func content(_ vm: OnboardingViewModel) -> some View {
        VStack(spacing: 0) {
            stepIndicator(vm.step)
                .padding(.top, 12)

            ScrollView {
                Group {
                    switch vm.step {
                    case .welcome: welcome
                    case .details: details(vm)
                    case .done: done(vm)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .scrollDismissesKeyboard(.interactively)

            footer(vm)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.step)
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(spacing: 20) {
            AnimatedImageView(name: "PugRunning")
                .frame(height: 180)

            VStack(spacing: 4) {
                Text("Welcome to PawPrint")
                    .font(PawprintTheme.displayFont(.title))
                    .foregroundStyle(PawprintTheme.accentDeep)
                    .multilineTextAlignment(.center)

                Text("Your dog's digital pawprint")
                    .font(PawprintTheme.font(.headline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                benefitRow(icon: "checklist", title: "Daily routines", text: "See today's walks and feeds at a glance")
                benefitRow(icon: "cross.case.fill", title: "Health history", text: "Vaccinations and treatments, never forgotten")
                benefitRow(icon: "book.fill", title: "Learn as you go", text: "Short guides for first-time owners")
            }
            .padding(.top, 40)
        }
    }

    private func details(_ vm: OnboardingViewModel) -> some View {
        @Bindable var form = vm
        let currentPhoto = vm.photoData
        return VStack(spacing: 18) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                PhotoPickerLabel(photoData: currentPhoto, size: 108, title: currentPhoto == nil ? "Add a photo" : "Change photo")
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

            Text("Tell us about your dog")
                .font(PawprintTheme.displayFont(.title2))
                .foregroundStyle(PawprintTheme.accentDeep)

            PawprintCard {
                VStack(spacing: 16) {
                    DogFormField(label: "Name", placeholder: "Bella", text: $form.name, focus: $focusedField, field: .name)
                    DogFormField(label: "Breed", placeholder: vm.isMixedBreed ? "Kelpie x Border Collie (optional)" : "Border Collie", text: $form.breed, focus: $focusedField, field: .breed)
                    MixedBreedToggle(isOn: $form.isMixedBreed)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(PawprintTheme.font(.caption, weight: .bold))
                                .foregroundStyle(PawprintTheme.textSecondary)
                                .textCase(.uppercase)
                            Stepper(value: $form.ageYears, in: 0...30) {
                                Text(vm.ageYears == 0 ? "Under 1 year" : "\(vm.ageYears) yr\(vm.ageYears == 1 ? "" : "s")")
                                    .font(PawprintTheme.font(.body))
                                    .foregroundStyle(PawprintTheme.textPrimary)
                            }
                            .frame(minHeight: 48)
                        }
                        DogFormField(label: "Weight (kg)", placeholder: "18.5", text: $form.weightText, keyboard: .decimalPad, focus: $focusedField, field: .weight)
                            .frame(width: 130)
                    }
                }
            }

            if let error = vm.errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(PawprintTheme.font(.footnote, weight: .semibold))
                    .foregroundStyle(PawprintTheme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Error: \(error)")
            }

            Text("Stays on this phone. Nothing is uploaded.")
                .font(PawprintTheme.font(.caption))
                .foregroundStyle(PawprintTheme.textSecondary)
        }
    }

    private func done(_ vm: OnboardingViewModel) -> some View {
        VStack(spacing: 18) {
            Image("PugHappy")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .accessibilityHidden(true)
            Text("\(vm.savedDog?.name ?? "Your dog") is all set")
                .font(PawprintTheme.displayFont(.title))
                .foregroundStyle(PawprintTheme.accentDeep)
                .multilineTextAlignment(.center)
            Text("Head to Routines to add your first walk or meal, and we'll keep today on track for you.")
                .font(PawprintTheme.font(.body))
                .foregroundStyle(PawprintTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 30)
    }

    // MARK: Chrome

    private func stepIndicator(_ step: OnboardingViewModel.Step) -> some View {
        HStack(spacing: 8) {
            ForEach(OnboardingViewModel.Step.allCases, id: \.rawValue) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? PawprintTheme.accent : PawprintTheme.border.opacity(0.5))
                    .frame(width: s == step ? 28 : 10, height: 6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step.rawValue + 1) of \(OnboardingViewModel.Step.allCases.count)")
    }

    private func footer(_ vm: OnboardingViewModel) -> some View {
        HStack(spacing: 12) {
            if vm.step == .details {
                Button("Back") { vm.back() }
                    .font(PawprintTheme.font(.headline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.accent)
                    .frame(minWidth: 72, minHeight: 52)
            }
            PrimaryButton(title: buttonTitle(vm.step)) {
                focusedField = nil
                switch vm.step {
                case .welcome:
                    vm.next()
                case .details:
                    if vm.saveDog() {
                        saveFeedback += 1
                        vm.next()
                    }
                case .done:
                    onComplete()
                }
            }
        }
    }

    private func buttonTitle(_ step: OnboardingViewModel.Step) -> String {
        switch step {
        case .welcome: return "Get started"
        case .details: return "Save profile"
        case .done: return "Let's go"
        }
    }

    private func benefitRow(icon: String, title: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(PawprintTheme.font(.headline, weight: .semibold))
                .foregroundStyle(PawprintTheme.onAccent)
                .frame(width: 40, height: 40)
                .background(PawprintTheme.accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(PawprintTheme.font(.subheadline, weight: .bold)).foregroundStyle(PawprintTheme.textPrimary)
                Text(text).font(PawprintTheme.font(.footnote)).foregroundStyle(PawprintTheme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(PawprintTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    OnboardingView {}
        .modelContainer(for: Dog.self, inMemory: true)
}
