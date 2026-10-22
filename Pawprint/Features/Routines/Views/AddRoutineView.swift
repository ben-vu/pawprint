//
//  AddRoutineView.swift
//  Routines feature (Sana)
//
//  Sheet for creating or editing a routine: name, category, when, how
//  often and whether to send a reminder. Pass a task to edit it.
//

import SwiftUI
import SwiftData

struct AddRoutineView: View {
    var task: RoutineTask? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddRoutineViewModel?
    @State private var confirmDelete = false
    @FocusState private var focusedField: Field?

    enum Field { case title }

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    form(viewModel)
                }
            }
            .navigationTitle(task == nil ? "New routine" : "Edit routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        if viewModel?.save() == true { dismiss() }
                    }
                    .fontWeight(.bold)
                }
            }
            .confirmationDialog("Delete this routine?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete routine", role: .destructive) {
                    if viewModel?.delete() == true { dismiss() }
                }
            }
        }
        .task {
            if viewModel == nil {
                let dog = try? SwiftDataDogRepository(context: context).fetchAll().first
                viewModel = AddRoutineViewModel(
                    repository: SwiftDataRoutineRepository(context: context),
                    notifications: UserNotificationService.shared,
                    dog: dog,
                    editing: task
                )
            }
        }
        .tint(PawprintTheme.accent)
    }

    private func form(_ vm: AddRoutineViewModel) -> some View {
        @Bindable var form = vm
        return ScrollView {
            VStack(spacing: 18) {
                PawprintCard {
                    VStack(alignment: .leading, spacing: 16) {
                        DogFormField(label: "Name", placeholder: vm.category.placeholder, text: $form.title, focus: $focusedField, field: .title)
                        fieldLabel("Category")
                        categoryGrid(selection: $form.category)
                    }
                }

                PawprintCard {
                    VStack(alignment: .leading, spacing: 12) {
                        fieldLabel("When")
                        DatePicker("Date", selection: $form.dueDate, displayedComponents: .date)
                        DatePicker("Time", selection: $form.dueDate, displayedComponents: .hourAndMinute)
                        fieldLabel("Repeat")
                            .padding(.top, 4)
                        Picker("Repeat", selection: $form.recurrence) {
                            ForEach(RoutineRecurrence.allCases) { Text($0.name).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                    .foregroundStyle(PawprintTheme.textPrimary)
                }

                PawprintCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $form.remindMe) {
                            Label("Remind me", systemImage: "bell.fill")
                                .foregroundStyle(PawprintTheme.textPrimary)
                        }
                        .onChange(of: vm.remindMe) {
                            Task { await vm.reminderToggled() }
                        }
                        if vm.notificationsDenied {
                            Text("Notifications are turned off for Pawprint. You can allow them in Settings.")
                                .font(PawprintTheme.font(.footnote))
                                .foregroundStyle(PawprintTheme.textSecondary)
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

                if vm.isEditing {
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Text("Delete routine")
                            .font(PawprintTheme.font(.subheadline, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 48)
                    }
                    .foregroundStyle(PawprintTheme.danger)
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

    private func categoryGrid(selection: Binding<RoutineCategory>) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(RoutineCategory.allCases) { category in
                let isSelected = selection.wrappedValue == category
                Button {
                    selection.wrappedValue = category
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: category.systemImage)
                            .font(PawprintTheme.font(.title3))
                        Text(category.name)
                            .font(PawprintTheme.font(.caption, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundStyle(isSelected ? PawprintTheme.onAccent : PawprintTheme.textPrimary)
                    .background(isSelected ? PawprintTheme.accent : PawprintTheme.surfaceRaised,
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    AddRoutineView()
        .modelContainer(for: [Dog.self, RoutineTask.self], inMemory: true)
}
