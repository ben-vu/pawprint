//
//  RoutineListView.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
//
//  Routines tab: overdue, today and upcoming tasks. Tap the circle to
//  tick a task off (or untick it), tap the row to edit, swipe left to
//  delete, + to add a new routine.
//

import SwiftUI
import SwiftData

struct RoutineListView: View {
    @Environment(\.modelContext) private var context
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @Query(sort: \Dog.createdAt) private var dogs: [Dog]
    @State private var viewModel: RoutineViewModel?
    @State private var showAdd = false
    @State private var editing: RoutineTask?
    @State private var completeFeedback = 0
    @State private var justAdded = false          // set by the add sheet, read when it closes
    @State private var showCelebration = false

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    if viewModel.isEmpty {
                        emptyState
                    } else {
                        list(viewModel)
                    }
                }
            }
            .navigationTitle("Routines")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarCircleButton(systemImage: "plus", label: "Add routine") { showAdd = true }
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .sheet(isPresented: $showAdd, onDismiss: {
                viewModel?.load()
                if justAdded {
                    justAdded = false
                    withAnimation { showCelebration = true }   // after the sheet has gone, so it isn't hidden
                }
            }) {
                AddRoutineView(onAdded: { justAdded = true })
            }
            .sheet(item: $editing, onDismiss: { viewModel?.load() }) { task in
                AddRoutineView(task: task)
            }
        }
        .overlay {
            if showCelebration {
                RoutineAddedCelebration {
                    withAnimation { showCelebration = false }
                }
                .transition(.opacity)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = RoutineViewModel(
                    repository: SwiftDataRoutineRepository(context: context),
                    notifications: UserNotificationService.shared
                )
            }
            viewModel?.load()
        }
        .onChange(of: selectedDogID) { viewModel?.load() }
        .sensoryFeedback(.success, trigger: completeFeedback)
        .tint(PawprintTheme.accent)
    }

    /// Which dog's routines these are, for the empty state. Switch dogs from the Home tab.
    private var activeDogName: String {
        ActiveDogUseCase().activeDog(in: dogs, selectedID: UUID(uuidString: selectedDogID))?.name ?? ""
    }

    private var emptyState: some View {
        ScrollView {
            PawprintCard {
                VStack(spacing: 14) {
                    PugEmptyState(
                        image: "PugLying",
                        title: activeDogName.isEmpty ? "No routines yet" : "\(activeDogName) has no routines yet",
                        message: "Add walks, meals and medication so nothing gets forgotten."
                    )
                    PrimaryButton(title: "Add a routine") { showAdd = true }
                }
            }
            .padding(20)
        }
    }

    private func list(_ vm: RoutineViewModel) -> some View {
        List {
            if let error = vm.errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(PawprintTheme.font(.footnote, weight: .semibold))
                    .foregroundStyle(PawprintTheme.danger)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            section("Overdue", tasks: vm.overdue, showsDate: true, vm: vm)
            section("Today", tasks: vm.todays, showsDate: false, vm: vm)
            section("Upcoming", tasks: vm.upcoming, showsDate: true, vm: vm)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable { vm.load() }
    }

    @ViewBuilder
    private func section(_ title: String, tasks: [RoutineTask], showsDate: Bool, vm: RoutineViewModel) -> some View {
        if !tasks.isEmpty {
            Section {
                ForEach(tasks) { task in
                    RoutineRow(task: task, showsDate: showsDate, isOverdue: title == "Overdue") {
                        if task.isCompleted {
                            vm.uncomplete(task)
                        } else {
                            vm.complete(task)
                            completeFeedback += 1
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editing = task }
                    .accessibilityAction(named: "Edit") { editing = task }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .swipeActions {
                        Button(role: .destructive) {
                            vm.delete(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text(title.uppercased())
                    .font(PawprintTheme.font(.caption, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(title == "Overdue" ? PawprintTheme.danger : PawprintTheme.textSecondary)
            }
        }
    }
}

private struct RoutineRow: View {
    let task: RoutineTask
    let showsDate: Bool
    let isOverdue: Bool
    let onToggle: () -> Void

    var body: some View {
        PawprintCard {
            HStack(spacing: 14) {
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(PawprintTheme.font(.title2))
                        .foregroundStyle(task.isCompleted ? PawprintTheme.success : PawprintTheme.border)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(task.isCompleted ? "Mark \(task.title) as not done" : "Mark \(task.title) as done")

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(PawprintTheme.font(.body, weight: .semibold))
                        .foregroundStyle(PawprintTheme.textPrimary)
                        .strikethrough(task.isCompleted, color: PawprintTheme.textSecondary)
                    HStack(spacing: 6) {
                        Text(showsDate
                             ? task.dueDate.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
                             : task.dueDate.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(isOverdue ? PawprintTheme.danger : PawprintTheme.textSecondary)
                        if task.recurrence != .once {
                            HStack(spacing: 3) {
                                Image(systemName: "repeat")
                                Text(task.repeatSummary)
                            }
                        }
                        if task.remindMe {
                            Image(systemName: "bell.fill")
                                .accessibilityLabel("Reminder on")
                        }
                    }
                    .font(PawprintTheme.font(.footnote))
                    .foregroundStyle(PawprintTheme.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: task.category.systemImage)
                    .font(PawprintTheme.font(.subheadline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(PawprintTheme.surfaceRaised, in: Circle())
                    .accessibilityLabel(task.category.name)
            }
        }
        .opacity(task.isCompleted ? 0.7 : 1)
    }
}

#Preview {
    RoutineListView()
        .modelContainer(for: [Dog.self, RoutineTask.self], inMemory: true)
}
