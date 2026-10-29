//
//  AddHealthRecordView.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//  Form for a new health record. Pick the kind of care, then the date it
//  was given and, if there is a follow-up, when it is next due. The sheet
//  only closes when the record saved; otherwise the reason is shown.
//

import SwiftUI

struct AddHealthRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HealthViewModel
    /// Called after a record is saved, so the list can celebrate once the sheet has gone.
    var onAdded: () -> Void = {}

    @State private var kind: HealthRecordKind = .vaccination
    @State private var title = HealthRecordKind.vaccination.name
    @State private var date = Date()
    @State private var hasDueDate = false
    @State private var nextDueDate = Date()
    @State private var notes = ""
    @State private var saveFeedback = 0
    @FocusState private var focusedField: Field?

    enum Field { case title, notes }

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                form
            }
            .navigationTitle("Add health record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.errorMessage = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        let saved = viewModel.addAHealthRecord(
                            title: title,
                            date: date,
                            nextDueDate: hasDueDate ? nextDueDate : nil,
                            notes: notes,
                            kind: kind
                        )
                        if saved {
                            saveFeedback += 1
                            onAdded()
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: hasDueDate) { applySuggestedDueDate() }
            .onChange(of: date) { applySuggestedDueDate() }
            .sensoryFeedback(.success, trigger: saveFeedback)
        }
        .tint(PawprintTheme.accent)
    }

    // Same card layout as the routine and dog forms so every sheet looks the same.
    private var form: some View {
        ScrollView {
            VStack(spacing: 18) {
                PawprintCard {
                    VStack(alignment: .leading, spacing: 16) {
                        fieldLabel("Type of care")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(HealthRecordKind.allCases) { option in
                                    kindChip(option)
                                }
                            }
                        }
                        DogFormField(label: "What happened?", placeholder: "e.g. Rabies vaccine", text: $title, focus: $focusedField, field: .title)
                        DatePicker("Date given", selection: $date, in: ...Date(), displayedComponents: .date)
                            .frame(minHeight: 44)
                    }
                    .foregroundStyle(PawprintTheme.textPrimary)
                }

                PawprintCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $hasDueDate) {
                            Label("Plan a follow-up", systemImage: "calendar.badge.clock")
                                .font(PawprintTheme.font(.subheadline, weight: .semibold))
                        }
                        .tint(PawprintTheme.accent)
                        .frame(minHeight: 44)
                        if hasDueDate {
                            DatePicker("Next due", selection: $nextDueDate, in: date..., displayedComponents: .date)
                                .frame(minHeight: 44)
                        }
                    }
                    .foregroundStyle(PawprintTheme.textPrimary)
                }

                PawprintCard {
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Notes")
                        TextField("Any extra details", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .notes)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(minHeight: 48)
                            .background(PawprintTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(PawprintTheme.textPrimary)
                            .accessibilityLabel("Notes")
                    }
                }

                if let error = viewModel.errorMessage {
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

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(PawprintTheme.font(.caption, weight: .bold))
            .foregroundStyle(PawprintTheme.textSecondary)
            .textCase(.uppercase)
    }

    private func kindChip(_ option: HealthRecordKind) -> some View {
        let isSelected = option == kind
        return Button {
            // Only replace the title if the person has not typed their own.
            if title == kind.name || title.isEmpty { title = option.name }
            kind = option
            applySuggestedDueDate()
        } label: {
            Label(option.name, systemImage: option.systemImage)
                .font(PawprintTheme.font(.subheadline, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .foregroundStyle(isSelected ? PawprintTheme.onAccent : PawprintTheme.textPrimary)
                .background(isSelected ? PawprintTheme.accent : PawprintTheme.surfaceRaised, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func applySuggestedDueDate() {
        guard hasDueDate else { return }
        nextDueDate = Calendar.current.date(byAdding: .day, value: kind.suggestedIntervalDays, to: date) ?? date
    }
}

#Preview {
    let repositories = PawprintRepositories.preview()
    let sampleDog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25.0)
    let viewModel = HealthViewModel(repository: repositories.health, dog: sampleDog)
    return AddHealthRecordView(viewModel: viewModel)
        .environment(repositories)
}
