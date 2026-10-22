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
import SwiftData

struct AddHealthRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HealthViewModel

    @State private var kind: HealthRecordKind = .vaccination
    @State private var title = HealthRecordKind.vaccination.name
    @State private var date = Date()
    @State private var hasDueDate = false
    @State private var nextDueDate = Date()
    @State private var notes = ""
    @State private var saveFeedback = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Type of care") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(HealthRecordKind.allCases) { option in
                                kindChip(option)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                }

                Section("What happened?") {
                    TextField("e.g. Rabies vaccine", text: $title)
                        .accessibilityLabel("What was done")
                    DatePicker("Date given", selection: $date, in: ...Date(), displayedComponents: .date)
                }

                Section("Next due") {
                    Toggle("Plan a follow-up", isOn: $hasDueDate)
                        .tint(PawprintTheme.accent)
                    if hasDueDate {
                        DatePicker("Next due", selection: $nextDueDate, in: date..., displayedComponents: .date)
                    }
                }

                Section("Notes") {
                    TextField("Any extra details", text: $notes, axis: .vertical)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(PawprintTheme.font(.footnote, weight: .semibold))
                            .foregroundStyle(PawprintTheme.danger)
                            .accessibilityLabel("Error: \(error)")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
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
                        let saved = viewModel.addAHealthRecord(
                            title: title,
                            date: date,
                            nextDueDate: hasDueDate ? nextDueDate : nil,
                            notes: notes,
                            kind: kind
                        )
                        if saved {
                            saveFeedback += 1
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Dog.self, HealthRecord.self, RoutineTask.self, configurations: config)
    let repo = SwiftDataHealthRepository(context: container.mainContext)
    let sampleDog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25.0)
    let viewModel = HealthViewModel(repository: repo, dog: sampleDog)

    return AddHealthRecordView(viewModel: viewModel)
        .modelContainer(container)
}
