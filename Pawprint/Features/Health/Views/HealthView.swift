//
//  HealthView.swift
//  Pawprint
//
//  Created by Alik Orgun on 21/10/2026.
//
//  One dog's health history: vaccinations, flea and worming treatments,
//  vet check-ups and grooming. Records with a follow-up show whether they
//  are overdue, due soon or later, and link to the matching Learn guide.
//

import SwiftUI
import SwiftData

struct HealthView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var viewModel: HealthViewModel?
    @State private var showingAddSheet = false

    let dog: Dog

    var body: some View {
        ZStack {
            PawprintTheme.background.ignoresSafeArea()

            if let viewModel {
                if viewModel.records.isEmpty {
                    emptyState
                } else {
                    list(viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Health")
        .navigationSubtitle(dog.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DogSwitcherMenu()
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Add health record")
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HealthViewModel(repository: SwiftDataHealthRepository(context: context), dog: dog)
            }
            viewModel?.load()
        }
        .sheet(isPresented: $showingAddSheet) {
            if let viewModel {
                AddHealthRecordView(viewModel: viewModel)
            }
        }
        .alert("Something went wrong", isPresented: errorIsShowing) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .tint(PawprintTheme.accent)
    }

    private var emptyState: some View {
        ScrollView {
            PawprintCard {
                VStack(spacing: 14) {
                    PugEmptyState(
                        image: "PugSick",
                        title: "No health records yet",
                        message: "Record \(dog.name)'s vaccinations, flea and worming treatments and vet visits, and Pawprint will keep track of what is due."
                    )
                    PrimaryButton(title: "Add a record") { showingAddSheet = true }
                }
            }
            .padding(20)
        }
    }

    private func list(_ vm: HealthViewModel) -> some View {
        List {
            ForEach(vm.records) { record in
                row(record)
                    .listRowBackground(PawprintTheme.surface)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            vm.delete(record)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func row(_ record: HealthRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: record.kind.systemImage)
                    .foregroundStyle(PawprintTheme.accent)
                    .accessibilityHidden(true)
                Text(record.title)
                    .font(PawprintTheme.font(.headline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.textPrimary)
            }

            Text("Given \(record.date.formatted(date: .abbreviated, time: .omitted))")
                .font(PawprintTheme.font(.subheadline))
                .foregroundStyle(PawprintTheme.textSecondary)

            if let due = record.nextDueDate {
                dueLabel(for: record, due: due)
            }

            if let guideID = record.kind.relatedGuideID {
                Button {
                    router?.open(.learn(tipID: guideID))
                } label: {
                    Label("Read the guide", systemImage: "book.fill")
                        .font(PawprintTheme.font(.footnote, weight: .semibold))
                        .frame(minHeight: 44, alignment: .leading)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
    }

    private func dueLabel(for record: HealthRecord, due: Date) -> some View {
        let status = record.dueStatus()
        let text = due.formatted(date: .abbreviated, time: .omitted)
        return Label(
            status == .overdue ? "Overdue: was due \(text)" : "Next due \(text)",
            systemImage: status == .overdue ? "exclamationmark.circle.fill" : "calendar"
        )
        .font(PawprintTheme.font(.footnote, weight: .semibold))
        .foregroundStyle(status == .overdue ? PawprintTheme.danger : (status == .dueSoon ? PawprintTheme.accent : PawprintTheme.textSecondary))
    }

    private var errorIsShowing: Binding<Bool> {
        Binding(
            get: { viewModel?.errorMessage != nil && !showingAddSheet },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Dog.self, HealthRecord.self, RoutineTask.self, configurations: config)
    let sampleDog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25.0)
    container.mainContext.insert(sampleDog)
    container.mainContext.insert(HealthRecord(title: "Rabies vaccine", date: .now.addingTimeInterval(-86400 * 300), nextDueDate: .now.addingTimeInterval(86400 * 5), dog: sampleDog, kind: .vaccination))

    return NavigationStack {
        HealthView(dog: sampleDog)
    }
    .modelContainer(container)
}
